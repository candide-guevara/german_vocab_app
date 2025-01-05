import bz2
import json
import pathlib
import re
import subprocess
import sys
import xml.sax

from merge_json_utils import *

def tmp_path_stem(p, suffix):
  return "__%s%s" % (p.stem.lstrip('_').split('.')[0], suffix)

def decompress_infile(infile):
  bziped_p = pathlib.Path(infile).resolve()
  xml_p = bziped_p.with_name(tmp_path_stem(bziped_p, ".xml"))
  if not xml_p.is_file():
    args = [ 'bzip2', '--decompress', '--keep',  bziped_p ]
    subprocess.check_output(args)
    bziped_p.with_name(bziped_p.stem).rename(xml_p)
  return xml_p

def get_outfile(infile):
  in_path = pathlib.Path(infile)
  return in_path.with_name(tmp_path_stem(in_path, ".json.bz2"))

class Handler(xml.sax.handler.ContentHandler):
  meaning_rx = re.compile(r'%(\d+)$')
  word_form = 'WordForm'
  lexical_entry = 'LexicalEntry'
  lemma = 'Lemma'
  feat = 'feat'
  at_type = 'partOfSpeech'
  at_gender = 'grammaticalGender'
  at_lemma = 'writtenForm'
  at_val = 'val'
  at_key = 'att'
  enum_noun = 'N'
  enum_gender = {
    'feminine' : 'die',
    'masculine' : 'der',
    'neuter' : 'das',
  }

  def __init__(self):
    self.entries = []
    self.alternate_spellings = {}
    self.elt_stack = []
    self.reset_word_entry()
    self.reset_lexical_entry()

  def result(self):
    return { 'entries' : self.entries, 'alternate_spellings': self.alternate_spellings, }

  def is_lemma(self, depth=-1):
    return self.elt_stack[depth] == Handler.lemma

  def is_lexical_entry(self):
    return self.elt_stack[-1] == Handler.lexical_entry

  def is_word_form(self, depth=-1):
    return self.elt_stack[depth] == Handler.word_form

  def reset_lexical_entry(self):
    self.meaning_index = 0
    self.pos = None # Note: word type can be in several places
    self.spellings = {}
    self.reset_word_entry()

  def reset_word_entry(self):
    self.word_entry = { "articles" : [], }

  def endElement(self, name):
    if self.is_word_form():
      if self.pos != POS_UNKNOWN:
        self.word_entry['pos'] = self.pos
        self.entries.append(self.word_entry)
    if self.is_lexical_entry():
      self.add_spellings()
      self.reset_lexical_entry()
    self.elt_stack.pop()

  def startElement(self, name, attrs):
    self.elt_stack.append(name)
    if self.is_word_form():
      self.reset_word_entry()
    self.dispatch(name, attrs)

  def dispatch(self, name, attrs):
    if name != Handler.feat: return
    key = attrs.get(Handler.at_key)
    val = attrs.get(Handler.at_val)
    if key == Handler.at_type:
      self.pos = enum_part_of_speech.get(val, POS_UNKNOWN)
    elif self.is_word_form(-2) and key == Handler.at_gender:
      self.word_entry['articles'].append(Handler.enum_gender[val])
    elif key == Handler.at_lemma:
      if self.is_word_form(-2):
        self.spellings.setdefault(self.meaning_index, set()).add(val)
        self.word_entry["hidx"] = self.meaning_index
        self.word_entry["lemma"] = val
      elif self.is_lemma(-2):
        m = Handler.meaning_rx.search(val)
        if m:
          self.meaning_index = int(m.group(1))
          self.spellings.setdefault(self.meaning_index, set()).add(val[:val.rfind('%')])
        else:
          self.spellings.setdefault(self.meaning_index, set()).add(val)

  def add_spellings(self):
    for idx, spells in self.spellings.items():
      if len(spells) < 2: continue
      for spell in spells:
        all_spells = self.alternate_spellings.setdefault(spell, {}).setdefault(idx, [])
        self.alternate_spellings[spell][idx] = sorted(spells.union(all_spells))


def load_xml(xml_p):
  '''
  # Note words with different meanings have a dedicated entry, the lemma is indexed using `%`
  <LexicalEntry id="E_s_10408">
    <feat partOfSpeech="N"/>
    <feat type="Vollartikel"/>
    <Lemma>
      <feat att="writtenForm" val="See%2"/>
    </Lemma>
    <WordForm>
      <feat att="grammaticalGender" val="feminine"/>
      <feat att="partOfSpeech" val="N"/>
      <feat att="writtenForm" val="See"/>
    </WordForm>
  </LexicalEntry>
  # Note words with different spellings are grouped in a single entry
  <LexicalEntry id="E_s_11308">
    <feat partOfSpeech="ADJ"/>
    <feat type="Basisartikel"/>
    <Lemma>
      <feat att="writtenForm" val="selbstgewählt"/>
    </Lemma>
    <WordForm>
      <feat att="writtenForm" val="selbstgewählt"/>
      <feat att="partOfSpeech" val="ADJ"/>
    </WordForm>
    <WordForm>
      <feat att="writtenForm" val="selbst gewählt"/>
      <feat att="partOfSpeech" val="ADJ"/>
    </WordForm>
  </LexicalEntry>
  # Note words with whose spelling is the same across different genders are grouped in a single entry
  <LexicalEntry id="E_7505539">
    <feat partOfSpeech="N"/>
    <feat type="Vollartikel"/>
    <Lemma>
      <feat att="writtenForm" val="Integrationsbeauftragte"/>
    </Lemma>
    <WordForm>
      <feat att="partOfSpeech" val="N"/>
      <feat att="writtenForm" val="Integrationsbeauftragte"/>
      <feat att="grammaticalGender" val="feminine"/>
    </WordForm>
    <WordForm>
      <feat att="partOfSpeech" val="N"/>
      <feat att="writtenForm" val="Integrationsbeauftragte"/>
      <feat att="grammaticalGender" val="masculine"/>
    </WordForm>
  </LexicalEntry>
  '''
  handler = Handler()
  xml.sax.parse(xml_p, handler)
  return handler.result()


def main(args):
  outpath = get_outfile(args[1])
  xml_p = decompress_infile(args[1])
  json_doc = load_xml(xml_p)
  if outpath.is_file(): outpath.unlink()
  with bz2.open(outpath, "wt") as f:
    f.write(json.dumps(json_doc))
  if xml_p.is_file(): xml_p.unlink()

if __name__ == "__main__":
  main(sys.argv)


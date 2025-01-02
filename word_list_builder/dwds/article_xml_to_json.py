import bz2
import json
import pathlib
import re
import subprocess
import sys
import xml.sax

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
  meaning_rx = re.compile(r'.+%(\d+)$')
  word_form = 'WordForm'
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
    self.result = []
    self.reset_state()

  def reset_state(self):
    self.word_entry = None
    self.is_noun = False
    self.is_in_lemma = False
    self.is_word_form = False
    self.meaning_index = 0

  def endElement(self, name):
    if name == Handler.word_form:
      if self.is_noun: self.result.append(self.word_entry)
      self.reset_state()
    elif name == Handler.lemma: self.is_in_lemma = False

  def startElement(self, name, attrs):
    if name == Handler.word_form:
      self.is_word_form = True
      self.word_entry = {
        "articles" : [],
        "sch" : [],
      }
    else: self.is_in_lemma |= (name == Handler.lemma)
    self.dispatch(name, attrs)

  def dispatch(self, name, attrs):
    if name != Handler.feat: return
    key = attrs.get(Handler.at_key)
    val = attrs.get(Handler.at_val)
    if self.is_word_form and key == Handler.at_type:
      self.is_noun = val == Handler.enum_noun
    elif self.is_word_form and key == Handler.at_gender:
      self.word_entry['articles'].append(Handler.enum_gender[val])
    elif self.is_word_form and key == Handler.at_lemma:
      self.word_entry['sch'].append({
        "hidx" : self.meaning_index,
        "lemma" : val,
      })
    elif self.is_in_lemma and key == Handler.at_lemma:
      m = Handler.meaning_rx.match(val)
      if m: self.meaning_index = int(m.group(1))

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
  return handler.result


def main(args):
  outpath = get_outfile(args[1])
  xml_p = decompress_infile(args[1])
  xml_doc = load_xml(xml_p)
  if outpath.is_file(): outpath.unlink()
  with bz2.open(outpath, "wt") as f:
    f.write(json.dumps(xml_doc))
  if xml_p.is_file(): xml_p.unlink()

if __name__ == "__main__":
  main(sys.argv)


import bz2
import json
import jsonschema
import pathlib
import re
import sys
import urllib

class Merged:
  def __init__(self):
    self.url_to_obj = {}
    self.wordidx_to_obj = {}
    self.missing = {}
    self.gender_file_funny_entries = []
    self.prufung_file_funny_entries = []
    self.wtype_mismatches = {}

  def get_obj(self, word, idx, wtype=None, ctx=None):
    obj = self.wordidx_to_obj.get((word, idx))
    prev_wtype = obj and obj["pos"]
    if not obj:
      d = self.missing.setdefault("%s_%s" % (word, idx), {})
      d[ctx] = d.get(ctx, 0) + 1
    elif prev_wtype and wtype and prev_wtype != wtype:
      prev = self.wtype_mismatches.setdefault(word, [])
      self.wtype_mismatches[word] = sorted(set(prev + [prev_wtype, wtype]))
    return obj

  def new_word_obj(self, url, word_idx):
    obj = {
      "articles" : [],
      "pos" : None,
      "freq" : None,
      "prufung" : None,
      "sch" : [
         { "hidx" : word_idx[1], "lemma" : word_idx[0] }
      ],
    }
    self.url_to_obj[url] = obj
    self.wordidx_to_obj[word_idx] = obj

  def calculate_stats(self):
    def stat_tuple(cnt):
      return [cnt, round(100*cnt/len(self.url_to_obj), 1)]
    cnt_has_freq = 0
    cnt_has_prufung = 0
    cnt_has_gender = 0
    cnt_has_several_spellings = 0
    cnt_has_several_meanings = sum( (t[1] > 1) for t in self.wordidx_to_obj.keys() )
    for v in self.url_to_obj.values():
      cnt_has_freq += (v['freq'] != None)
      cnt_has_prufung += (v['prufung'] != None)
      cnt_has_gender += (len(v['articles']) > 0)
      cnt_has_several_spellings += (len(v['sch']) > 1)
    missing_per_ctx = {}
    for m in self.missing.values():
      for k,v in m.items():
        missing_per_ctx.setdefault(k, 0)
        missing_per_ctx[k] += 1
    stats = {
      "total_words" : len(self.url_to_obj),
      "has_freq" : stat_tuple(cnt_has_freq),
      "has_gender" : stat_tuple(cnt_has_gender),
      "has_prufung" : stat_tuple(cnt_has_prufung),
      "has_several_spellings" : stat_tuple(cnt_has_several_spellings),
      "has_several_meanings" : stat_tuple(cnt_has_several_meanings),
      "missing_per_ctx" : missing_per_ctx,
    }
    return stats

  def write_merged(self, outpath):
    entries = []
    index_url = {}
    index_word = {}
    for k,v in self.url_to_obj.items():
      index_url[k.split('/')[-1]] = len(entries)
      for spell in v['sch']:
        index_word.setdefault(spell['lemma'], []).append(len(entries))
      entries.append(v)
    for k,v in index_word.items():
      if len(set(v)) != len(v):
        raise Exception("Malformed word index entry: %s -> %r" % (k, v))
    with bz2.open(outpath, "wt") as f:
      f.write(json.dumps({
        "entries"    : entries,
        "url_root"   : "https://www.dwds.de/wb/",
        "index_url"  : index_url,
        "index_word" : index_word,
      }))

  def write_fiaschi(self, outpath):
    if outpath.is_file(): outpath.unlink()
    with bz2.open(outpath, "wt") as f:
      f.write(json.dumps({
        "missing" : self.missing,
        "gender_file_funny_entries" : self.gender_file_funny_entries,
        "prufung_file_funny_entries" : self.prufung_file_funny_entries,
        "wtype_mismatches" : self.wtype_mismatches,
      }, indent=2))


def load_json(path):
  with bz2.open(path, "rb") as f:
    return json.load(f)

# Note u'' strings deal with unicode codepoints.
# Ex: \u00b2 is the code point for superscript 1.
#     but \uc2b2 is the utf8 encode for codepoint \u00b2.
rx_superscript = re.compile(u'([\u2070\u00b9\u00b2\u00b3\u2074\u2075\u2076\u2077\u2078\u2079]+)$')
enum_superscript = { u'\u00b9' : 1, u'\u00b2' : 2, u'\u00b3' : 3,
                     u'\u2074' : 4, u'\u2075' : 5, u'\u2076' : 6, u'\u2077' : 7, u'\u2078' : 8, u'\u2079' : 9, }
def extract_superscript(string):
  m = rx_superscript.search(string)
  if m: return enum_superscript[m.group(1)]
  return 0

rx_url_idx = re.compile(r'#(\d+)$')
def get_url_idx(url):
  m = rx_url_idx.search(url)
  if m: return int(m.group(1))
  unescaped = urllib.parse.unquote(url)
  return extract_superscript(unescaped)

def build_url_to_obj(word_path):
  merged = Merged()
  for k,v in load_json(word_path).items():
    if v in merged.url_to_obj:
      raise Exception("Repeated url: %s -> %s and %s" % (v, url_to_obj[v], k))
    idx = extract_superscript(k)
    if idx: word_idx = (k[:-1], idx)
    else: word_idx = (k,0)
    url_idx = get_url_idx(v)
    if word_idx[1] != url_idx:
      raise Exception("Meaning index mismatch: %s -> %r and %r" % (v, word_idx, url_idx))
    merged.new_word_obj(v, word_idx)
  return merged

def merge_synonyms(synonym_path, merged):
  """
  # Root object: array
  # Note words with different meanings will appear once in each synonym group (aka synset).
  words_to_synonyms = [
     "Fortführung",
     "Wiederaufnahme"
  ]
  # Root object: dict
  # Note the keys can have superscripts when there are different meanings.
  words_to_url = { "See¹" : "https://www.dwds.de/wb/See#1" }
  """
  pass

def merge_frequencies(freq_path, merged):
  """
  # Root object: array
  # Note words with different meanings will have separate entries,
  # `lemma` may be the same or may have a superscript (prefer to decode superscript from url)
  words_to_freq = {
    "date" : "2020-08-10",
    "freq" : 5,
    "lemma" : "damit",
    "pos" : "Konjunktion",
    "type" : "Vollartikel",
    "url" : "https://www.dwds.de/wb/damit#2"
  }
  """
  for v in load_json(freq_path):
    wtype = v.get("pos")
    freq = v.get("freq")
    if freq == 'n/a': freq = None
    word = v["lemma"]
    idx = extract_superscript(word)
    url_idx = get_url_idx(v["url"])
    if idx:
      if idx != url_idx:
        raise Exception("Meaning index mismatch: %s -> %r" % (word, v))
      word = word[:-1]
    if freq and freq < 0:
      raise Exception("Invalid frequency for: %s -> %r" % (word, v))
    obj = merged.get_obj(word, url_idx, wtype, "merge_frequencies")
    if not obj: continue
    obj["freq"] = freq
    if wtype: obj["pos"] = wtype

def merge_genders(gender_path, merged):
  """
  # Root object: array
  # Note1 `sch` stands for schreibung (in case there are different spellings)
  # Note2 words with different meanings will have separate entries sharing the same `sch.lemma`
  # however `sch.hidx` will index the different entries (start at 1, 0 means there is only a single meaning).
  words_to_gender = {
    "articles" : [ "die" ],
    "sch" : [
       { "hidx" : null, "lemma" : "Abfahrt" }
    ],
  }
  """
  for v in load_json(gender_path):
    articles = v.get("articles")
    sch = v.get("sch")
    if not sch:
      raise Exception("Expecting spelling")
    if not articles:
      merged.gender_file_funny_entries.append(v)
      continue
    for spell in sch:
      word = spell["lemma"]
      idx = spell["hidx"]
      obj = merged.get_obj(word, idx, "Substantiv", "merge_genders")
      if not obj: continue
      obj["articles"] = sorted(set(articles + obj["articles"]))
      obj["pos"] = "Substantiv"

def merge_prufung_levels(paths, merged):
  """
  # Root object: array
  # Note1 `sch` stands for schreibung (in case there are different spellings)
  # Note2 words with different meanings will have separate entries sharing the same `sch.lemma`
  # however `sch.hidx` will index the different entries (start at 1, 0 means there is only a single meaning).
  words_to_XX_level = {
    "articles" : [ "die" ],
    "genera" : [ "fem." ],
    "pos" : "Substantiv",
    "sch" : [
       { "hidx" : null, "lemma" : "Abfahrt" }
    ],
    "url" : "https://www.dwds.de/wb/Abfahrt"
  }
  # Plural only words are tagged like this:
  {
     "articles" : [],
     "genera" : [],
     "onlypl" : "nur im Plural",
     "pos" : "Substantiv",
     "sch" : [
        { "hidx" : null, "lemma" : "Eltern" }
     ],
     "url" : "https://www.dwds.de/wb/Eltern"
  }
  """
  for lvl, path in paths:
    for v in load_json(path):
      articles = v.get("articles")
      sch = v.get("sch")
      wtype = v.get("pos")
      url = v.get("url")
      if not sch:
        raise Exception("Expecting spelling")
      if not url:
        merged.prufung_file_funny_entries.append(v)
        continue
      if wtype == 'Substantiv' and not articles:
        if v.get('onlypl') == "nur im Plural":
          articles = [ 'die' ]
        else:
          merged.prufung_file_funny_entries.append(v)
          continue

      for spell in sch:
        word = spell["lemma"]
        idx = int(spell["hidx"]) if spell["hidx"] else 0
        obj = merged.get_obj(word, idx, wtype, "merge_prufung_levels")
        if not obj: continue
        if url not in merged.url_to_obj:
          raise Exception("No url found for entry: %r", v)
        obj["articles"] = sorted(articles)
        obj["pos"] = wtype
        obj["prufung"] = lvl

def validate_merged(schema_path, merged):
  for k,v in merged.items():
    jsonschema.validate(instance=v, schema=schema_path)

def main(args):
  root = pathlib.Path('.').resolve()
  merged = build_url_to_obj(root.joinpath('__words_to_url.json.bz2'))
  merge_frequencies(root.joinpath('__words_to_freq.json.bz2'), merged)
  merge_genders(root.joinpath('__words_to_gender.json.bz2'), merged)
  merge_synonyms(root.joinpath('__words_to_synonyms.json.bz2'), merged)
  merge_prufung_levels([
      ('a1', root.joinpath('__words_to_a1_level.json.bz2')),
      ('a2', root.joinpath('__words_to_a2_level.json.bz2')),
      ('b1', root.joinpath('__words_to_b1_level.json.bz2')),
    ], merged)
  #validate_merged(root.joinpath('words.jsonschema'), merged)
  merged.write_fiaschi(root.joinpath('__fiaschi.json.bz2'))
  merged.write_merged(root.joinpath('__words.json.bz2'))
  print(json.dumps(merged.calculate_stats(), indent=4))

if __name__ == "__main__":
  main(sys.argv)


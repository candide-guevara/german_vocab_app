import argparse
import json
import jsonschema
import pathlib
import sys

from merge_json_utils import *
from merge_json_filter import WordFilter
from merge_json_state import Merged

def build_url_to_obj(word_path):
  merged = Merged()
  for k,v in load_json(word_path).items():
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
    if freq == 'n/a': freq = -1
    elif isinstance(freq, str):
      raise Exception("Invalid frequency for: %s -> %r" % (word, v))
    word = v["lemma"]
    idx = extract_superscript(word)
    url_idx = get_url_idx(v["url"])
    if idx:
      if idx != url_idx:
        raise Exception("Meaning index mismatch: %s -> %r" % (word, v))
      word = word[:-1]
    obj = merged.get_obj(word, url_idx, "merge_frequencies",
                         expect={'pos' : wtype})
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
      obj = merged.get_obj(word, idx, "merge_genders",
                           expect={'pos' : "Substantiv"})
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
        obj = merged.get_obj(word, idx, "merge_prufung_levels",
                             expect={'pos' : wtype, 'url' : get_url_suffix(url)})
        if not obj: continue
        obj["articles"] = sorted(articles)
        obj["pos"] = wtype
        obj["prufung"] = lvl

def validate_merged(schema_path, merged):
  for k,v in merged.items():
    jsonschema.validate(instance=v, schema=schema_path)

def main(args):
  in_root = pathlib.Path(args.in_root).resolve()
  out_root = pathlib.Path(args.out_root).resolve()
  with open(pathlib.Path(args.config), 'rt') as f: config = json.load(f)

  merged = build_url_to_obj(in_root.joinpath('__words_to_url.json.bz2'))
  merge_frequencies(in_root.joinpath('__words_to_freq.json.bz2'), merged)
  merge_genders(in_root.joinpath('__words_to_gender.json.bz2'), merged)
  merge_synonyms(in_root.joinpath('__words_to_synonyms.json.bz2'), merged)
  merge_prufung_levels([
      ('a1', in_root.joinpath('__words_to_a1_level.json.bz2')),
      ('a2', in_root.joinpath('__words_to_a2_level.json.bz2')),
      ('b1', in_root.joinpath('__words_to_b1_level.json.bz2')),
    ], merged)
  #validate_merged(in_root.joinpath('words.jsonschema'), merged)
  merged.filter_words(WordFilter.build(config))
  merged.write_merged(out_root.joinpath('__words.json.bz2'))
  merged.write_fiaschi(out_root.joinpath('__fiaschi.json.bz2'))
  print('DONE, stats', json.dumps(merged.calculate_stats(), indent=4))

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="See https://github.com/candide-guevara/german_vocab_app")
  parser.add_argument(
      '--config',
      type=str,
      default='./merge_json_files.config.json',
      help='Fullpath to configuration file'
  )
  parser.add_argument(
      '--out_root',
      type=str,
      default='.',
      help='Directory where to output files'
  )
  parser.add_argument(
      '--in_root',
      type=str,
      default='.',
      help='Directory where the source files are'
  )
  main(parser.parse_args())



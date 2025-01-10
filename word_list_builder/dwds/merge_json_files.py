import argparse
import json
import pathlib
import sys

from merge_json_filter import WordFilter
from merge_json_state import Merged
from merge_json_tag_words import WordTagger
from merge_json_utils import *

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
    pos = pos_name_to_enum(v.get("pos"))
    freq = v.get("freq")
    if freq == 'n/a': freq = FREQ_UNKNOWN
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
                         expect={'pos' : pos.value})
    if not obj: continue
    obj["freq"] = freq
    if pos != Pos.UNKNOWN: obj["pos"] = pos.value

def merge_alternate_spellings(root, merged):
  """
  # Root object: dict
  spellings = { alternate_spellings: {
  "Apartment" : {
       "0" : [
          "Apartment",
          "App.",
          "Appartement"
       ]
  }}
  """
  for idxs in root['alternate_spellings'].values():
    for idx, spells in idxs.items():
      merged.add_spellings(idx, set(spells))

def merge_genders(gender_json, merged):
  """
  # Root object: dict
  # Note1 `sch` stands for schreibung (in case there are different spellings)
  # Note2 words with different meanings will have separate entries sharing the same `lemma`
  # however `hidx` will index the different entries (start at 1, 0 means there is only a single meaning).
  words_to_gender = { entries: [{
    "articles" : [ Article.DIE.value ],
     "hidx" : 0,
     "lemma" : "Abfahrt",
     "pos" : 29
  }]}
  """
  # Words ending with these suffixes are always plural and may not contain gender hints.
  always_plural_rx = re.compile(
    r'..(eltern|beschwerden|trümmer|ferien|spesen|leute|kosten|verhältnisse|sachen|daten|mittel|dinger?|[ -]?[jJ]ahre)$')
  for v in gender_json['entries']:
    pos = pos_idx_to_enum(v.get('pos'))
    if pos != Pos.SUBSTANTIV: continue
    articles = [ n for n in v.get("articles", []) if n != Article.UNKNOWN.value ]
    word = v["lemma"]
    idx = v["hidx"]
    obj = merged.get_obj(word, idx, "merge_genders",
                         expect={'pos' : pos.value})
    if not articles and always_plural_rx.search(word):
      articles = [ Article.DIE.value ]
    if not articles and not stricter_is_funky(word):
      merged.gender_file_funny_entries.append(v)
      continue
    if not obj: continue
    obj["articles"] = sorted(set(articles + obj["articles"]))
    if pos != Pos.UNKNOWN: obj["pos"] = pos.value

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
      articles = [ Article[n.upper()].value for n in v.get("articles", []) ]
      if Article.UNKNOWN.value in articles:
        raise Exception("Unknown article: %r" % v.get("articles", []))
      sch = v.get("sch")
      pos = pos_name_to_enum(v.get("pos"))
      url = get_url_suffix(v.get("url"))
      if not sch:
        raise Exception("Expecting spelling")
      if not url:
        merged.prufung_file_funny_entries.append(v)
        continue
      if pos == Pos.SUBSTANTIV and not articles:
        if v.get('onlypl') == "nur im Plural":
          articles = [ Article.DIE.value ]
        else:
          merged.prufung_file_funny_entries.append(v)
          continue

      spellings = {}
      for spell in sch:
        word = spell["lemma"]
        idx = int(spell.get("hidx") or 0)
        spellings.setdefault(idx, set()).add(word)
        obj = merged.get_obj(word, idx, "merge_prufung_levels",
                             expect={'pos' : pos.value, 'url' : url})
        if not obj: continue
        obj["articles"] = sorted(set(articles + obj["articles"]))
        if pos != Pos.UNKNOWN: obj["pos"] = pos.value
        obj["prufung"] = lvl.value
      for idx, spells in spellings.items():
        merged.add_spellings(idx, spells)

def main(args):
  in_root = pathlib.Path(args.in_root).resolve()
  out_root = pathlib.Path(args.out_root).resolve()
  outfile = out_root.joinpath('words.json.gz')
  install_path = pathlib.Path(args.install_root).resolve().joinpath('app/assets', outfile.name)
  with open(pathlib.Path(args.config), 'rt') as f: config = json.load(f)

  merged = build_url_to_obj(in_root.joinpath('__words_to_url.json.bz2'))
  merge_frequencies(in_root.joinpath('__words_to_freq.json.bz2'), merged)
  gender_and_spelling_json = load_json(
    in_root.joinpath('__words_to_gender_and_spellings.json.bz2'))
  merge_genders(gender_and_spelling_json, merged)
  merge_alternate_spellings(gender_and_spelling_json, merged)
  merge_prufung_levels([
      (Prufung.A1, in_root.joinpath('__words_to_a1_level.json.bz2')),
      (Prufung.A2, in_root.joinpath('__words_to_a2_level.json.bz2')),
      (Prufung.B1, in_root.joinpath('__words_to_b1_level.json.bz2')),
    ], merged)
  #merge_synonyms(in_root.joinpath('__words_to_synonyms.json.bz2'), merged)
  WordTagger(config).add_tags(merged)
  merged.filter_words(WordFilter.build(config))

  merged.write_merged(outfile,
                      in_root.joinpath('words.schema.json'))
  merged.write_fiaschi(out_root.joinpath('__fiaschi.json.bz2'))
  install_path.write_bytes(outfile.read_bytes())
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
      '--install_root',
      type=str,
      default='../..',
      help='Directory root for the flutter app where the assets should be installed'
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



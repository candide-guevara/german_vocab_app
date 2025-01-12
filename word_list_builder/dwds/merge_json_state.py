import gzip
import json
import jsonschema

from merge_json_utils import *

class Merged:
  def __init__(self):
    self.url_set = set()
    self.all_words = set()
    self.wordidx_to_obj = {}
    # Example for words: (Appartment, 0) and (Apartment, 0)
    # There will be 2 entries in `self.alternate_spellings`:
    # { ("Appartment", 0) : [ "Appartment", "Apartment" ],
    #   ("Apartment", 0) : [ "Appartment", "Apartment" ], }
    self.alternate_spellings = {}
    self.missing = {}
    self.gender_file_funny_entries = []
    self.prufung_file_funny_entries = []
    self.mismatches = {}

  def get_obj(self, word, idx, ctx=None, expect={}):
    obj = self.wordidx_to_obj.get((word, idx))
    funky = is_funky(word)
    if not obj and not funky:
      d = self.missing.setdefault("%s_%s" % (word, idx), {})
      d[ctx] = d.get(ctx, 0) + 1
    if funky or not obj: return obj
    for k,v in expect.items():
      prev_val = obj[k]
      if not prev_val or prev_val == v: continue
      prev = self.mismatches.setdefault(word, [])
      self.mismatches[word] = sorted(set(prev + ["%s:%s:%s/%s" % (ctx, k, prev_val, v)]))
    return obj

  def add_spellings(self, idx, spells):
    if len(spells) < 2: return
    for spell in spells:
      k = (spell, int(idx))
      all_spells = self.alternate_spellings.setdefault(k, [])
      self.alternate_spellings[k] = sorted(spells.union(all_spells))

  def filter_words(self, wfilter):
    if wfilter.is_noop(): return
    new_url_set = set()
    new_wordidx_to_obj = {}
    new_alternate_spellings = {}

    for k,v in self.wordidx_to_obj.items():
      if not wfilter.ok(v): continue
      new_wordidx_to_obj[k] = v
      new_url_set.add(v['url'])

    words_to_include = set( t[0] for t in new_wordidx_to_obj.keys() )
    for k,spells in self.alternate_spellings.items():
      if k[0] not in words_to_include: continue
      new_spells = [ s for s in spells if s in words_to_include ]
      if len(new_spells) > 1:
        new_alternate_spellings[k] = new_spells

    self.all_words = words_to_include
    self.url_set = new_url_set
    self.wordidx_to_obj = new_wordidx_to_obj
    self.alternate_spellings = new_alternate_spellings

  def new_word_obj(self, url, word_idx):
    url_suffix = get_url_suffix(url)
    obj = {
      "articles" : [],
      "pos" : Pos.UNKNOWN.value,
      "freq" : FREQ_UNKNOWN,
      "prufung" : Prufung.UNKNOWN.value,
      "hidx" : word_idx[1],
      "lemma" : word_idx[0],
      'url' : url_suffix,
    }
    if url_suffix in self.url_set:
      raise Exception("Repeated url: %s -> %r\n%r" % (url_suffix, obj, self.wordidx_to_obj.set(word_idx)))
    self.url_set.add(url_suffix)
    self.all_words.add(word_idx[0])
    self.wordidx_to_obj[word_idx] = obj

  def calculate_stats(self):
    total = len(self.wordidx_to_obj)
    def stat_tuple(cnt,tot=total):
      return "%d, %.1f%%" % (cnt, round(100*cnt/tot, 1))
    cnt_has_freq = 0
    cnt_has_prufung = 0
    cnt_has_gender = 0
    cnt_has_tags = { e.value : 0 for e in Tag }
    cnt_pos = { e.value : 0 for e in Pos }
    cnt_has_several_meanings = sum( (t[1] > 1) for t in self.wordidx_to_obj.keys() )
    for v in self.wordidx_to_obj.values():
      cnt_has_freq += (v.get('freq', FREQ_UNKNOWN) >= 0)
      cnt_has_prufung += (v['prufung'] != Prufung.UNKNOWN.value)
      cnt_has_gender += (len(v['articles']) > 0)
      cnt_pos[v['pos']] += 1
      for t in v['tags']: cnt_has_tags[t] += 1
    stats = {
      "total_words" : total,
      "has_freq" : stat_tuple(cnt_has_freq),
      "has_gender" : stat_tuple(cnt_has_gender, cnt_pos[Pos.SUBSTANTIV.value]),
      "has_prufung" : stat_tuple(cnt_has_prufung),
      "has_tags" : { tag_idx_to_enum(k).name : stat_tuple(v) for k,v in cnt_has_tags.items() },
      "cnt_pos" : { pos_idx_to_enum(k).name : stat_tuple(v) for k,v in cnt_pos.items() if v },
      "several_meanings" : stat_tuple(cnt_has_several_meanings),
      "alternate_spellings" : stat_tuple(len(self.alternate_spellings)),
    }
    return stats

  def alternate_spellings_using_entry_index(self):
    wordidx_entry = { k:e for (e,k) in enumerate(self.wordidx_to_obj.keys()) }
    result = { str(wordidx_entry.get(k, -1)):v for k,v in self.alternate_spellings.items() }
    if '-1' in results: del result["-1"]
    #if len(result) != len(self.alternate_spellings):
    #  raise Exception("alternate_spellings missing keys got %d expected %d : %r"
    #                  % (len(result), len(self.alternate_spellings),
    #                     [ k for k in self.alternate_spellings.keys() if k not in wordidx_entry ]))
    return result

  def write_merged(self, outpath, schema_path):
    if not self.wordidx_to_obj:
      raise Exception("no words")
    if not self.alternate_spellings:
      raise Exception("no alternate spellings")
    to_write = {
      "entries"    : list(self.wordidx_to_obj.values()),
      "alternate_spellings" : self.alternate_spellings_using_entry_index(),
      "url_root"   : "https://www.dwds.de/wb/",
    }
    with open(schema_path, 'rt') as schema_f:
      schema = json.load(schema_f)
      try: jsonschema.validate(instance=to_write, schema=schema)
      except jsonschema.ValidationError as e:
        e.instance = "TRUNCATED"
        e.schema = "See %s" % schema_path
        raise
    with gzip.open(outpath, "wt") as f:
      f.write(json.dumps(to_write))

  def write_fiaschi(self, outpath):
    if outpath.is_file(): outpath.unlink()
    with bz2.open(outpath, "wt") as f:
      f.write(json.dumps({
        "missing_len" : len(self.missing),
        "missing" : self.missing,
        "gender_file_funny_entries_len" : len(self.gender_file_funny_entries),
        "gender_file_funny_entries" : self.gender_file_funny_entries,
        "prufung_file_funny_entries_len" : len(self.prufung_file_funny_entries),
        "prufung_file_funny_entries" : self.prufung_file_funny_entries,
        "mismatches_len" : len(self.mismatches),
        "mismatches" : self.mismatches,
      }, indent=2))


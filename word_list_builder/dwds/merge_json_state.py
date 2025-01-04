from merge_json_utils import *

class Merged:
  def __init__(self):
    self.url_set = set()
    self.wordidx_to_obj = {}
    self.missing = {}
    self.gender_file_funny_entries = {}
    self.prufung_file_funny_entries = []
    self.mismatches = {}

  def get_obj(self, word, idx, ctx=None, expect={}):
    obj = self.wordidx_to_obj.get((word, idx))
    if not obj and len(word) > 1 and not funky_chars.search(word):
      d = self.missing.setdefault("%s_%s" % (word, idx), {})
      d[ctx] = d.get(ctx, 0) + 1
    if not obj: return None
    for k,v in expect.items():
      prev_val = obj[k]
      if not prev_val or prev_val == v: continue
      prev = self.mismatches.setdefault(word, [])
      self.mismatches[word] = sorted(set(prev + ["%s:%s:%s/%s" % (ctx, k, prev_val, v)]))
    return obj

  def filter_words(self, wfilter):
    if wfilter.is_noop(): return
    new_url_set = set()
    new_wordidx_to_obj = {}
    for k,v in self.wordidx_to_obj.items():
      if not wfilter.ok(v): continue
      new_wordidx_to_obj[k] = v
      new_url_set.add(v['url'])
    self.url_set = new_url_set
    self.wordidx_to_obj = new_wordidx_to_obj

  def new_word_obj(self, url, word_idx):
    url_suffix = get_url_suffix(url)
    obj = {
      "articles" : [],
      "pos" : None,
      "freq" : None,
      "prufung" : None,
      "sch" : [
         { "hidx" : word_idx[1], "lemma" : word_idx[0] }
      ],
      'url' : url_suffix,
    }
    if url_suffix in self.url_set:
      raise Exception("Repeated url: %s -> %r\n%r" % (url_suffix, obj, self.wordidx_to_obj.set(word_idx)))
    self.url_set.add(url_suffix)
    self.wordidx_to_obj[word_idx] = obj

  def calculate_stats(self):
    def stat_tuple(cnt):
      return [cnt, round(100*cnt/len(self.wordidx_to_obj), 1)]
    cnt_has_freq = 0
    cnt_has_prufung = 0
    cnt_has_gender = 0
    cnt_has_several_spellings = 0
    cnt_has_several_meanings = sum( (t[1] > 1) for t in self.wordidx_to_obj.keys() )
    for v in self.wordidx_to_obj.values():
      cnt_has_freq += (v.get('freq', FREQ_UNKNOWN) >= 0)
      cnt_has_prufung += (v['prufung'] != None)
      cnt_has_gender += (len(v['articles']) > 0)
      cnt_has_several_spellings += (len(v['sch']) > 1)
    missing_per_ctx = {}
    for m in self.missing.values():
      for k,v in m.items():
        missing_per_ctx.setdefault(k, 0)
        missing_per_ctx[k] += 1
    stats = {
      "total_words" : len(self.wordidx_to_obj),
      "has_freq" : stat_tuple(cnt_has_freq),
      "has_gender" : stat_tuple(cnt_has_gender),
      "has_prufung" : stat_tuple(cnt_has_prufung),
      "has_several_spellings" : stat_tuple(cnt_has_several_spellings),
      "has_several_meanings" : stat_tuple(cnt_has_several_meanings),
      "missing_per_ctx" : missing_per_ctx,
    }
    return stats

  def write_merged(self, outpath):
    with bz2.open(outpath, "wt") as f:
      f.write(json.dumps({
        "entries"    : list(self.wordidx_to_obj.values()),
        "url_root"   : "https://www.dwds.de/wb/",
      }))

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


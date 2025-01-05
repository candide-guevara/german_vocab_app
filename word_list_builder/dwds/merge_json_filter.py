import re

from merge_json_utils import *

class WordFilter():
  @classmethod
  def build(k, config):
    any_filters = any( k.startswith('filter_') for k in config.keys() )
    if not any_filters:
      class NopFilter:
        def is_noop(self): return True
        def ok(self, entry): return True
        def word_ok(self, word): return True
      return NopFilter()

    f = k()
    f.freq_thres = config.get('filter_freq_thres_greater_or_eq', FREQ_UNKNOWN)
    f.pos_filter = config.get('filter_include_pos', [])
    f.chars_filter = config.get('filter_words_with_non_german_chars', False)
    f.min_len = config.get('filter_words_shorter_than', 0)
    f.blacklist = config.get('filter_rx_blacklist', [])
    if f.pos_filter:
      f.pos_filter = [ enum_pos[k] for k in f.pos_filter ]
      if any( p == POS_UNKNOWN for p in f.pos_filter):
        raise Exception("Bad POS filter: %r", f.pos_filter)
    if f.blacklist:
      f.blacklist = [ re.compile(r) for r in f.blacklist ]
    return f

  def is_noop(self): return False

  def word_ok(self, word):
    if len(word) < self.min_len: return False
    if self.chars_filter and not german_chars_rx.search(word):
      return False
    if any( r.fullmatch(word) for r in self.blacklist ):
      return False
    return True

  def ok(self, entry):
    if entry["freq"] < self.freq_thres: return False
    if self.pos_filter and entry["pos"] not in self.pos_filter:
      return False
    return self.word_ok(entry["lemma"])


from merge_json_utils import *

class WordFilter():
  @classmethod
  def build(k, config):
    any_filters = any( config.get(k) for k in ['freq_thres', 'pos_filter', ] )
    if not any_filters:
      class NopFilter:
        def is_noop(self): return True
        def ok(self, entry): return True
      return NopFilter()

    f = k()
    f.freq_thres = config.get('freq_thres') or -2
    f.pos_filter = config.get('pos_filter') or []
    if f.pos_filter:
      f.pos_filter = [ enum_pos[k] for k in f.pos_filter ]
    return f

  def is_noop(self): return False

  def ok(self, entry):
    if entry["freq"] < self.freq_thres: return False
    if self.pos_filter and entry["pos"] not in self.pos_filter:
      return False
    return True


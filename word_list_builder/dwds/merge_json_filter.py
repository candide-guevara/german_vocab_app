class WordFilter():
  @classmethod
  def build(k, config):
    any_filters = any( config.get(k) for k in ['freq_thres', 'wtype_filter', ] )
    if not any_filters:
      class NopFilter:
        def is_noop(self): return True
        def ok(self, entry): return True
      return NopFilter()

    f = k()
    f.freq_thres = config.get('freq_thres') or -2
    f.wtype_filter = config.get('wtype_filter') or []
    return f

  def is_noop(self): return False

  def ok(self, entry):
    if entry["freq"] < self.freq_thres: return False
    if self.wtype_filter and entry["pos"] not in self.wtype_filter:
      return False
    return True


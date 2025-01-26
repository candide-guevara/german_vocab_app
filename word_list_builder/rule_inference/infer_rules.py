import pandas as pd
import random

from dwds.merge_json_utils import *

class RuleEntry:
  kExampleLen = 10

  def __init__(self, s_entry, df):
    self.tot = sum( len(v) for v in s_entry.gender.values() )
    self.perc = {}
    self.example = {}
    for a,v in s_entry.gender.items():
      self.perc[a] = len(v) / self.tot
      random.shuffle(v)
      l = v[:RuleEntry.kExampleLen]
      self.example[a] = sorted([ df.iloc[i].word for i in l ])

  def pretty_print(self, indent):
    return [
      "%stotal: %d" % (indent, self.tot),
      "%sperc: %r" % (indent, { Article(a).name:("%d" % int(100*self.perc[a])) for a in sorted(self.perc.keys()) }),
      "%s%s: %r" % (indent, Article.DER, self.example.get(Article.DER.value, [])),
      "%s%s: %r" % (indent, Article.DIE, self.example.get(Article.DIE.value, [])),
      "%s%s: %r" % (indent, Article.DAS, self.example.get(Article.DAS.value, [])),
    ]

  def __repr__(self):
    return "%d %r" % (self.tot, self.perc)

class Rules:
  kMinTot = 100
  kMinDisc = 0.95

  def __init__(self):
    self.by_len = {}

  def add(self, l, suffix, s_entry, df):
    d = self.by_len.setdefault(l, {})
    d.setdefault(suffix, RuleEntry(s_entry, df))

  def pretty_print(self, indent):
    lines = []
    new_indent = "%s  " % indent
    chl_indent = "%s    " % indent
    for l,r_map in self.by_len.items():
      lines.append("%slength: %d" % (indent, l))
      ranked_tup = sorted([ (v.tot, k) for k,v in r_map.items() ], reverse=True)
      for _,k in ranked_tup[:3]:
        lines.append("%ssuffix: %s" % (new_indent, k))
        lines.extend(r_map[k].pretty_print(chl_indent))
      lines.append("")
    return lines

  def __repr__(self):
    return "%r" % { k:len(v) for k,v in self.by_len.items() }

def keep(s_entry):
  tot = sum( len(v) for v in s_entry.gender.values() )
  if tot < Rules.kMinTot: return False
  return any( (len(v)/tot) > Rules.kMinDisc for v in s_entry.gender.values() )
  
def infer_rules(suffixes, df):
  r = Rules()
  for l,s_map in suffixes.by_len.items():
    for s,s_entry in s_map.items():
      if not keep(s_entry): continue
      r.add(l, s, s_entry, df)
  print(r)
  print(r.by_len[2])
  return r


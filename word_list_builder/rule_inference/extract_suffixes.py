import pandas as pd
import re

class SuffixEntry:
  def __init__(self, suffix):
    self.gender = {}

  def add(self, idx, row):
    self.gender.setdefault(row.article, []).append(idx)

  def __repr__(self):
    return "%r" % { k:len(v) for k,v in self.gender.items() }

class Suffixes:
  kMinLen = 1
  kMaxLen = 5 # inclusive
  blacklist_rx = re.compile(u'..(ismus|chen|haus|zeit|erin|heit|keit|schaft|tät|tion|ung)$')

  def __init__(self):
    self.by_len = {}

  def add_word(self, idx, row):
    for l in range(Suffixes.kMinLen, Suffixes.kMaxLen+1):
      if Suffixes.blacklist_rx.search(row.word): continue
      if len(row.word) < 2*l: continue
      s = row.word[-l:]
      d = self.by_len.setdefault(l, {})
      e = d.setdefault(s, SuffixEntry(s))
      e.add(idx, row)

  def __repr__(self):
    return "%r" % { k:len(v) for k,v in self.by_len.items() }

def extract_suffixes(df):
  s = Suffixes()
  for idx,row in df.iterrows():
    s.add_word(idx, row)
  #print(s)
  #print(s.by_len[2])
  return s 


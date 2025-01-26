import gzip
import io
import json
import pandas as pd

from dwds.merge_json_utils import *

def read_dict_to_csv(dictpath):
  csv = io.StringIO()
  with gzip.open(dictpath, 'rb') as f:
    jsonObj = json.load(f)
  assert jsonObj['entries']
  for entry in jsonObj['entries']:
    if entry['pos'] == Pos.SUBSTANTIV.value and entry['articles']:
      if not german_chars_strict_rx.search(entry['lemma']) \
         or entry['lemma'] == entry['lemma'].upper(): continue
      csv.write('"%s",%d,%d\n' % (entry['lemma'], entry['hidx'], entry['articles'][0]))
  csv.seek(0)
  return csv

def read_dict(dictpath):
  csv = read_dict_to_csv(dictpath)
  df = pd.read_csv(
    csv,
    names = ['word', 'hidx', 'article'],
    index_col=False
  )
  #print(df)
  return df


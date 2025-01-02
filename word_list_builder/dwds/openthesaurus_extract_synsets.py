import bz2
import datetime as dt
import io
import json
import pandas as pd
import pathlib
import subprocess
import sys

def tmp_path_stem(p, suffix):
  return "__%s%s" % (p.stem.lstrip('_').split('.')[0], suffix)

def get_outfile(infile):
  in_path = pathlib.Path(infile)
  return in_path.with_name(tmp_path_stem(in_path, ".json.bz2"))

def load_synset(infile):
  bziped_p = pathlib.Path(infile).resolve()
  sqlite_p = bziped_p.with_name(tmp_path_stem(bziped_p, ".sqlite"))
  if not sqlite_p.is_file():
    args = [ 'bzip2', '--decompress', '--keep',  bziped_p ]
    subprocess.check_output(args)
    bziped_p.with_name(bziped_p.stem).rename(sqlite_p)
  # BE CAREFUL it is a trap!
  # `synset.is_visible` is a weird kind of integer, HEX is needed.
  query = '''
  SELECT s.id, t.word
  FROM synset s
    inner join term t on t.synset_id = s.id
  WHERE HEX(s.is_visible) = '01';
  '''
  query_with_antonyms = '''
  SELECT s.id, t.word, t2.word
  FROM synset s
    inner join term t on t.synset_id = s.id
    left join term_link tl on t.id in (tl.target_term_id, tl.term_id)
    left join term t2 on t2.id in (tl.target_term_id, tl.term_id)
  WHERE HEX(s.is_visible) = '01'
    AND t.id != coalesce(t2.id,-1)
    AND t2.word is not null;
  '''
  # use `--init` to ignore .sqliterc
  args = [ 'sqlite3', sqlite_p, "--init", "/dev/null", "--readonly", "--batch", "--csv", "--noheader", query ]
  return sqlite_p, subprocess.check_output(args).decode('utf-8')

def synset_str_to_json(synset_str):
  def list_accumulate(series):
    return sorted(series.astype(str).to_list())
  df = pd.read_csv(io.StringIO(synset_str),
                   names=['synset', 'word'], index_col='synset')
  g = df.groupby('synset')
  json_list = [ r for r in g.word.aggregate(list_accumulate) ]
  return json.dumps(json_list)


def main(args):
  outpath = get_outfile(args[1])
  tmp_p, synset_str = load_synset(args[1])
  json_str = synset_str_to_json(synset_str)
  if outpath.is_file(): outpath.unlink()
  with bz2.open(outpath, "wt") as f:
    f.write(json_str)
  if tmp_p.is_file(): tmp_p.unlink()

if __name__ == "__main__":
  main(sys.argv)



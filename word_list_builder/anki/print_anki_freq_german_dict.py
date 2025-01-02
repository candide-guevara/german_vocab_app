import datetime as dt
import pathlib
import subprocess
import sys

def get_outfile(infile):
  bziped_p = pathlib.Path(infile).resolve()
  outpath  = pathlib.Path(bziped_p.parent,
                          "__%s_%s.txt" % (bziped_p.stem, dt.datetime.now().strftime("%Y%m%d")))
  if outpath.is_file(): outpath.unlink()
  return outpath

def load_hexdump(infile):
  bziped_p = pathlib.Path(infile).resolve()
  sqlite_p = bziped_p.with_name("__%s" % bziped_p.stem)
  if not sqlite_p.is_file():
    args = [ 'bzip2', '--decompress', '--keep',  bziped_p ]
    subprocess.check_output(args)
    bziped_p.with_name(bziped_p.stem).rename(sqlite_p)
  args = [ 'sqlite3', sqlite_p, 'select HEX(flds || "   ") from notes;' ]
  return subprocess.check_output(args).decode('utf-8')

def split_in_lines_and_fields(hexdump_str):
  lines = hexdump_str.split("202020")
  hexdump_split = []
  for line in lines:
    hexdump_split.append(line.split('1F'))
  return hexdump_split[:-1]

def convert_text(hexdump_split):
  words = []
  for line in hexdump_split:
    word = []
    for tok in line:
      h = bytes.fromhex(tok)
      word.append(h.decode('utf-8'))
    words.append(word)
  return words

def save_words_to_file(outpath, words):
  with open(outpath, 'w') as f:
    for word in words:
      print(word[1], "\n ", meaning_to_str(word[2:6]), file=f)
      if word[6]: print(" ", meaning_to_str(word[6:10]), file=f)
      if word[10]: print(" ", meaning_to_str(word[10:14]), file=f)
      print("", file=f)

def meaning_to_str(meaning):
  return "%s: %s\n    %s\n    %s" % tuple(meaning)

def main(args):
  hexdump_str = load_hexdump(args[1])
  hexdump_split = split_in_lines_and_fields(hexdump_str)
  words = convert_text(hexdump_split)
  save_words_to_file(get_outfile(args[1]), words)

if __name__ == "__main__":
  main(sys.argv)


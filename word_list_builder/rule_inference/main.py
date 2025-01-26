import argparse
import pathlib

from dict_to_df import read_dict
from extract_suffixes import extract_suffixes
from infer_rules import infer_rules

def main(args):
  df = read_dict(pathlib.Path(args.dict_file).resolve())
  suffixes = extract_suffixes(df)
  rules = infer_rules(suffixes, df)
  print('\n'.join(rules.pretty_print('')))

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="See https://github.com/candide-guevara/german_vocab_app")
  parser.add_argument(
      '--dict_file',
      type=str,
      default='dwds/words.json.gz',
      help='Filepath to read the dictionary from.'
  )
  main(parser.parse_args())


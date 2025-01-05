import pathlib
import re

from merge_json_utils import *

class WordTagger:
  english_dict_path = '/usr/share/dict/american-english'

  def __init__(self, config):
    self.english_words = self.build_english_dict(WordTagger.english_dict_path)

  def build_english_dict(self, path):
    if not pathlib.Path(path).is_file():
      raise Exception("Cannot file english word file at %r, did you install the dictionnary for your linux distro?"
                      % path)
    words = set()
    start_cap_rx = re.compile(r'^[A-Z]')
    with open(path, 'rt') as f:
      for word in f.read().splitlines():
        if len(word) < 7 or start_cap_rx.search(word): continue
        words.add(word)
    return words

  fem_endings_rx = re.compile(u'(keit|heit|ung)$')
  neu_endings_rx = re.compile(u'(chen)$')
  mas_endings_rx = re.compile(u'(markt|ismus)$')
  def trivial_gender(self, word, articles):
    if len(articles) > 1: return False
    if self.fem_endings_rx.search(word) and 'die' in articles: return True
    if self.neu_endings_rx.search(word) and 'das' in articles: return True
    if self.mas_endings_rx.search(word) and 'der' in articles: return True
    return False

  def likely_english(self, word, pos):
    if pos not in [POS_SUBSTANTIV, POS_ADJECTIV]: return False
    return word.lower() in self.english_words

  ber_endings_rx = re.compile(u'(..+)(er|erin)$')
  def profession(self, word, pos, all_words):
    if pos != POS_SUBSTANTIV: return False
    m = self.ber_endings_rx.search(word)
    if not m: return None
    fem = "%ser" % m.group(1)
    mas = "%serin" % m.group(1)
    if (fem in all_words) and (mas in all_words):
      if m.group(2) == 'er': return TAG_MAS_PROFESSION
      return TAG_FEM_PROFESSION
    return None

  def add_tags(self, merged):
    for entry in merged.wordidx_to_obj.values():
      word = entry["lemma"]
      tags = []
      pos = entry['pos']
      if self.trivial_gender(word, entry['articles']): tags.append(TAG_TRIVIAL_GENDER)
      if self.likely_english(word, pos): tags.append(TAG_LIKELY_ENGLISH)
      prof_tag = self.profession(word, pos, merged.all_words)
      if prof_tag: tags.append(prof_tag)
      if is_funky(word): tags.append(TAG_FUNKY)
      entry["tags"] = sorted(tags)


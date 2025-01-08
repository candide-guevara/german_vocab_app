from enum import Enum
import bz2
import json
import re
import urllib

def load_json(path):
  with bz2.open(path, "rb") as f:
    return json.load(f)

periodic_elt_rx = re.compile(r'^A[cglmrstu]|B[aehikr]|C[adelorsu]|D[syb]|E[rsu]|F[elmr]|G[ade]|H[efgos]|I[rn]|K[r]|L[airu]|M[cdgnot]|N[aep]|O[gs]|P[abdmst]|R[abefghnu]|S[bcegimnr]|T[abcehilmnr]|U[uh]|V[su]|W[sn]|X[e]|Y[b]|Z[nr]$')

# If a word contains chars outside of this set, then it is likely not important.
german_chars_rx = re.compile(u'^[a-zA-ZäöüÄÖÜß0-9 \-_]+$')
def is_funky(word):
  return len(word) < 2 or word.isupper() or not german_chars_rx.search(word)

# Note u'' strings deal with unicode codepoints.
# Ex: \u00b2 is the code point for superscript 1.
#     but \uc2b2 is the utf8 encode for codepoint \u00b2.
rx_superscript = re.compile(u'([\u2070\u00b9\u00b2\u00b3\u2074\u2075\u2076\u2077\u2078\u2079]+)$')
enum_superscript = { u'\u00b9' : 1, u'\u00b2' : 2, u'\u00b3' : 3,
                     u'\u2074' : 4, u'\u2075' : 5, u'\u2076' : 6, u'\u2077' : 7, u'\u2078' : 8, u'\u2079' : 9, }
def extract_superscript(string):
  m = rx_superscript.search(string)
  if m: return enum_superscript[m.group(1)]
  return 0

def get_url_suffix(url): return url.split('/')[-1]

rx_url_idx = re.compile(r'#(\d+)$')
def get_url_idx(url):
  m = rx_url_idx.search(url)
  if m: return int(m.group(1))
  unescaped = urllib.parse.unquote(url)
  return extract_superscript(unescaped)

FREQ_UNKNOWN = -1

class Pos(Enum):
  UNKNOWN  = 0
  ADJEKTIV = 1
  ADVERB = 2
  AFFIX = 3
  BESTIMMTER_ARTIKEL = 4
  BRUCHZAHL = 5
  DEMONSTRATIVPRONOMEN = 6
  EIGENNAME = 7
  IMPERATIV = 8
  INDEFINITPRONOMEN = 9
  INTERJEKTION = 10
  INTERROGATIVPRONOMEN = 11
  KARDINALZAHL = 12
  KOMPARATIV = 13
  KONJUNKTION = 14
  MEHRWORTAUSDRUCK = 15
  ORDINALZAHL = 16
  PARTIKEL = 17
  PARTIZIPIALES_ADJEKTIV = 18
  PARTIZIPIALES_ADVERB = 19
  PERSONALPRONOMEN = 20
  POSSESSIVPRONOMEN = 21
  PRAEPOSITION = 22
  PRAEPOSITION_ARTIKEL = 23
  PRONOMEN = 24
  PRONOMINALADVERB = 25
  REFLEXIVPRONOMEN = 26
  RELATIVPRONOMEN = 27
  REZIPROKES_PRONOMEN = 28
  SUBSTANTIV = 29
  SUPERLATIV = 30
  VERB = 31
  SYMBOL = 32

__pos_name_to_idx = {
  'Adjektiv': 1,
  'Adverb': 2,
  'Affix': 3,
  'bestimmter Artikel': 4,
  'Bruchzahl': 5,
  'Demonstrativpronomen': 6,
  'Eigenname': 7,
  'Imperativ': 8,
  'Indefinitpronomen': 9,
  'Interjektion': 10,
  'Interrogativpronomen': 11,
  'Kardinalzahl': 12,
  'Komparativ': 13,
  'Konjunktion': 14,
  'Mehrwortausdruck': 15,
  'Ordinalzahl': 16,
  'Partikel': 17,
  'partizipiales Adjektiv': 18,
  'partizipiales Adverb': 19,
  'Personalpronomen': 20,
  'Possessivpronomen': 21,
  'Präposition': 22,
  'Präposition + Artikel': 23,
  'Pronomen': 24,
  'Pronominaladverb': 25,
  'Reflexivpronomen': 26,
  'Relativpronomen': 27,
  'reziprokes Pronomen': 28,
  'Substantiv': 29,
  'Superlativ': 30,
  'Verb': 31,
  'Symbol': 32,
}
__pos_idx_to_enum = list(Pos)
def pos_idx_to_enum(idx):
  return __pos_idx_to_enum[idx or Pos.UNKNOWN.value]
def pos_name_to_enum(pos_name):
  return __pos_idx_to_enum[__pos_name_to_idx.get(pos_name, Pos.UNKNOWN.value)]

__part_of_speech_to_pos_enum = {
  'N' : Pos.SUBSTANTIV,
  'V' : Pos.VERB,
  'ADJ' : Pos.ADJEKTIV,
  'ADV' : Pos.ADVERB,
}
def part_of_speech_to_pos(part_of_speech):
  return __part_of_speech_to_pos_enum.get(part_of_speech, Pos.UNKNOWN)

class Article(Enum):
  UNKNOWN = 0
  DER = 1
  DIE = 2
  DAS = 3

__grammatical_gender_to_article = {
  'feminine' : Article.DIE,
  'masculine' : Article.DER,
  'neuter' : Article.DAS,
}
def grammatical_gender_to_article(gg):
  return __grammatical_gender_to_article.get(gg, Article.UNKNOWN)

class Tag(Enum):
  UNKNOWN = 0
  TRIVIAL_GENDER = 1
  LIKELY_ENGLISH = 2
  FEM_PROFESSION = 3
  MAS_PROFESSION = 4
  FUNKY = 5

__tag_idx_to_enum = list(Tag)
def tag_idx_to_enum(idx):
  return __tag_idx_to_enum[idx or Tag.UNKNOWN.value]

class Prufung(Enum):
  UNKNOWN = 0
  A1 = 1
  A2 = 2
  B1 = 3


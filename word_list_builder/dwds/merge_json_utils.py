import bz2
import json
import re
import urllib

def load_json(path):
  with bz2.open(path, "rb") as f:
    return json.load(f)

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

POS_UNKNOWN = 0
POS_SUBSTANTIV = 29
enum_pos = {
  'UNKNOWN' : POS_UNKNOWN,
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
  'Substantiv': POS_SUBSTANTIV,
  'Superlativ': 30,
  'Verb': 31,
}


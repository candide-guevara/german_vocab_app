# Building the German wordlist

## From dwds.de

[DWDS][2] provides json dumps for their dictionary.
There are several sources that need to be joined in order to get a complete set (see [script][3]).

* List of words to their definition url
* List of words to their frequency
* List of words to their gender
* List of words corresponding to A1, A2, B1
  * AFAIK there are no official lists for the more advanced levels
* List of words to their synonyms from openthesaurus.de

```
bash download.sh
python merge_json_files.py
```

## Anki (deprecated)

The word source is an Anki set called [A Frequency Dictionary of German][0], which is based on a [real dictionary][1].
I modified some of the words to add better examples for words with many meanings (like prepositions).

Anki files is just a zipped sqlite file. To process the anki raw data into a readable text file:

```
python print_anki_freq_german_dict.py frequency_dict_german_anki.sqlite.bz2 
```

## Deduced gender rules

Trying all possible suffixes and looking at how good they are at predicting gender, yields the following results:

```
length: 2
  suffix: ag
    total: 356
    perc: {'DER': '99', 'DAS': '0'}
    Article.DER: ['Airbag', 'Bombenanschlag', 'Fachverlag', 'Großauftrag', 'Ostermontag', 'Ritterschlag', 'Sonntagnachmittag', 'Straßenbelag', 'Vortrag', 'Weihnachtsfeiertag']
    Article.DAS: ['Mittag', 'Stag']
  suffix: ik
    total: 313
    perc: {'DER': '2', 'DIE': '97', 'DAS': '0'}
    Article.DER: ['Generalstreik', 'Hungerstreik', 'Katholik', 'Plastik', 'Sputnik', 'Streik', 'Warnstreik']
    Article.DIE: ['Flüchtlingspolitik', 'Infografik', 'Instrumentalmusik', 'Mischtechnik', 'Sicherheitstechnik', 'Spielstatistik', 'Sportgymnastik', 'Tierklinik', 'Unternehmenspolitik', 'Wirtschaftspolitik']
    Article.DAS: ['Mosaik']
  suffix: pe
    total: 208
    perc: {'DER': '2', 'DIE': '96', 'DAS': '0'}
    Article.DER: ['Hype', 'Knappe', 'Pope', 'Rappe', 'Type', 'Welpe']
    Article.DIE: ['Außentreppe', 'Fachgruppe', 'Fangruppe', 'Kindergruppe', 'Mädchengruppe', 'Pumpe', 'Rebellengruppe', 'Trachtengruppe', 'Umwälzpumpe', 'Unternehmensgruppe']
    Article.DAS: ['Cape', 'Tape']

length: 3
  suffix: ler
    total: 320
    perc: {'DER': '99', 'DAS': '0'}
    Article.DER: ['Automobilhersteller', 'Bittsteller', 'Boiler', 'Einzelhändler', 'Ermittler', 'Gebrauchtwagenhändler', 'Geisteswissenschaftler', 'Gürtler', 'Immobilienmakler', 'Markenhersteller']
    Article.DAS: ['Koller']
  suffix: lle
    total: 304
    perc: {'DER': '3', 'DIE': '96', 'DAS': '0'}
    Article.DER: ['Cyberkriminelle', 'Geselle', 'Homosexuelle', 'Industrielle', 'Intellektuelle', 'Junggeselle', 'Kriminelle', 'Oppositionelle', 'Transsexuelle', 'Widerwille']
    Article.DIE: ['Außenstelle', 'Forelle', 'Gazelle', 'Knolle', 'Parzelle', 'Schalterhalle', 'Schnalle', 'Schulturnhalle', 'Sonderrolle', 'Sonnenbrille']
    Article.DAS: ['Gefälle', 'Promille']
  suffix: age
    total: 258
    perc: {'DIE': '99', 'DAS': '0'}
    Article.DIE: ['Anschlußfrage', 'Außenanlage', 'Camouflage', 'Diskussionsgrundlage', 'Erstauflage', 'Höhenlage', 'Produktionsanlage', 'Schulanlage', 'Spielanlage', 'Textpassage']
    Article.DAS: ['Cottage']

length: 4
  suffix: elle
    total: 166
    perc: {'DER': '4', 'DIE': '95'}
    Article.DER: ['Cyberkriminelle', 'Homosexuelle', 'Industrielle', 'Intellektuelle', 'Junggeselle', 'Kriminelle', 'Oppositionelle', 'Transsexuelle']
    Article.DIE: ['Druckstelle', 'Fehlerquelle', 'Gefahrenstelle', 'Gefängniszelle', 'Hitzewelle', 'Koordinierungsstelle', 'Teilzeitstelle', 'Verkaufsstelle', 'Zertifizierungsstelle', 'Zweigstelle']
  suffix: lage
    total: 161
    perc: {'DIE': '100'}
    Article.DIE: ['Gefühlslage', 'Gesamtanlage', 'Großanlage', 'Heimniederlage', 'Persiflage', 'Schneelage', 'Sportanlage', 'Tempelanlage', 'Verkehrslage', 'Wirtschaftslage']
  suffix: tand
    total: 133
    perc: {'DER': '100'}
    Article.DER: ['Ausbildungsstand', 'Gemeindevorstand', 'Gemeinschaftsstand', 'Kreisvorstand', 'Mißstand', 'Sachverstand', 'Spielstand', 'Verkaufsstand', 'Vermögensgegenstand', 'Vorruhestand']
```

[0]: https://ankiweb.net/shared/info/912352287
[1]: https://www.amazon.com/Frequency-Dictionary-German-Vocabulary-Dictionaries/dp/1138659789
[2]: https://www.dwds.de/d/api#export
[3]: dwds/download.sh


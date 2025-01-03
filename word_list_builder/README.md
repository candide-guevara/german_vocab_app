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

[0]: https://ankiweb.net/shared/info/912352287
[1]: https://www.amazon.com/Frequency-Dictionary-German-Vocabulary-Dictionaries/dp/1138659789
[2]: https://www.dwds.de/d/api#export
[3]: dwds/download.sh


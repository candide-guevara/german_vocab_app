import 'package:flutter/material.dart';

final kAppTitle = "German Vocab";
final int kReferenceWidth = 300;

// Keep in sync with `../../word_list_builder/dwds/merge_json_utils.py`
enum Article { Unknown, der, die, das, }
final Map<String, Article> RArticle = { for(var v in Article.values) v.name:v };

enum PosType {
  Unknown,
  Adjektiv,
  Adverb,
  Affix,
  BestimmterArtikel,
  Bruchzahl,
  DemonstrativPronomen,
  Eigenname,
  Imperativ,
  IndefinitPronomen,
  Interjektion,
  InterrogativPronomen,
  Kardinalzahl,
  Komparativ,
  Konjunktion,
  Mehrwortausdruck,
  Ordinalzahl,
  Partikel,
  PartizipialesAdjektiv,
  PartizipialesAdverb,
  PersonalPronomen,
  PossessivPronomen,
  Preaposition,
  PreapositionArtikel,
  Pronomen,
  PronominalAdverb,
  ReflexivPronomen,
  RelativPronomen,
  ReziprokesPronomen,
  Substantiv,
  Superlativ,
  Verb,
}
final Map<String, PosType> RPosType = { for(var v in PosType.values) v.name:v };

enum PrunfungType { Unknown, a1, a2, b1, }
final Map<String, PrunfungType> RPrunfungType = { for(var v in PrunfungType.values) v.name:v };

enum TagType {
  Unknown,
  TrivialGender,
  LikelyEnglish,
  FemProfession,
  MasProfession,
  Funky,
}
final Map<String, TagType> RTagType = { for(var v in TagType.values) v.name:v };


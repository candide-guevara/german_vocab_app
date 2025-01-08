import 'dictionary_entry.dart';

class Dictionary {
  Map<String, dynamic> _d = <String, dynamic>{};
  bool get isEmpty => _d.isEmpty;

  Dictionary(Map<String, dynamic> jsonDict): _d = jsonDict;
  Dictionary.empty(): _d = <String, dynamic>{};

  DEntry byIdx(int idx) => DEntry.fromJson(_d['entries'][idx]);
}


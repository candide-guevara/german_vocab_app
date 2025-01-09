import '../utils.dart';

class GenderGameConfig {
  final int word_cnt;
  final int min_freq;
  final List<TagType> exclude_tags;

  GenderGameConfig(this.word_cnt,
                   {this.min_freq = 0, this.exclude_tags = const []});
}


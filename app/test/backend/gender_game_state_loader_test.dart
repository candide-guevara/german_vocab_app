import 'package:test/test.dart';
import 'package:matcher/expect.dart';
import 'package:app/backend/gender_game_state.dart';
import 'package:app/backend/gender_game_state_loader.dart';
import 'package:app/backend/persistence_store.dart';
import 'shared_preferences_fake.dart';

void main() {
  Persistence.test_only_init(SharedPreferencesFake());

  test('GenderGameHistoryLoader_load_save_clear', () async {
    GenderGameHistoryLoader.init();
    await GenderGameHistoryLoader.isLoaded();

    final ggh = GenderGameHistoryLoader.h;
    ggh.history.add(HistoryEntry.empty('word', 3));
    ggh.past_games.add(PastGame(DateTime(2020, 12, 12), 6, 7));
    final gghStr = ggh.toString();

    await GenderGameHistoryLoader.save();
    final new_ggh = await GenderGameHistoryLoader.load();
    expect(new_ggh.toString(), equals(gghStr));
    expect(GenderGameHistoryLoader.h.toString(), equals(gghStr));

    await GenderGameHistoryLoader.clear();
    expect(GenderGameHistoryLoader.h.toString(), equals(GenderGameHistory.empty().toString()));
    final empty_ggh = await GenderGameHistoryLoader.load();
    expect(empty_ggh.toString(), equals(GenderGameHistory.empty().toString()));
  });
}


import 'package:app/backend/persistence_store.dart';
import 'package:matcher/expect.dart';
import 'package:test/test.dart';
import 'shared_preferences_fake.dart';

void main() {
  test('Persistence_from_to_json', () {
    final fake_prefs = SharedPreferencesFake();
    final Map<String, String> jsonObj = { 'coucou':'salut' };
    fake_prefs.setJson('key', jsonObj);
    final jsonNew = fake_prefs.getJson('key');
    expect(jsonNew, equals(jsonObj));
  });
}


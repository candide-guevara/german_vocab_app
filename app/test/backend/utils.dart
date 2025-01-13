import 'package:matcher/expect.dart';

void compareJsonStr(String t, String expected) {
  expect(
    expected.replaceAll(RegExp(r'\s'), ''),
    equalsIgnoringWhitespace(t));
}


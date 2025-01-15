import 'package:flutter/foundation.dart';

class ExceptionAndStack implements Exception {
  final String msg;
  final Object err;
  final StackTrace trace;
  ExceptionAndStack(this.msg, this.err, this.trace);
  String toString() {
    return "${msg}: ${err}\n${framesStr()}";
  }
  String framesStr() {
    final List<StackFrame> frames = StackFrame.fromStackTrace(trace);
    return frames
      .skipWhile((s) => !s.source.contains('package:german_vocab_app'))
      .take(3)
      .map((s) => "${s.source}").join("\n");
  }
}


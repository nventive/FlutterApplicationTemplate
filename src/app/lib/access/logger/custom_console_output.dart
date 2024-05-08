import 'dart:developer';

import 'package:logger/logger.dart';

/// Workaround for colorization on iOS.
/// See https://github.com/flutter/flutter/issues/64491 for more details.
final class CustomConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    event.lines.forEach(buffer.writeln);
    log(buffer.toString());
  }
}

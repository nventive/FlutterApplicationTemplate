import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';

/// Custom implementation of [LogOutput] to write the log output into a file.
final class CustomFileOutput extends LogOutput {
  final File _file;
  final bool _overrideExisting;
  final Encoding _encoding;

  /// Regex used to remove ansi color codes from from log files.
  final _ansiPattern = RegExp(r'\x1B\[\d+(;\d+)*m');

  /// It's a reference to [_file] used to write logs inside.
  IOSink? _sink;

  CustomFileOutput({
    required File file,
    bool overrideExisting = false,
    Encoding encoding = utf8,
  })  : _encoding = encoding,
        _overrideExisting = overrideExisting,
        _file = file;

  @override
  Future<void> init() async {
    _sink = _file.openWrite(
      mode: _overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: _encoding,
    );
  }

  @override
  void output(OutputEvent event) async {
    // File may have been deleted.
    if (!_file.existsSync()) {
      await _file.create();
      await destroy();
      await init();
    }

    _sink?.writeAll(
        event.lines.map((line) => line.replaceAll(_ansiPattern, '')), '\n');
    _sink?.writeln();
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}

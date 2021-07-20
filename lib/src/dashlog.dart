import 'dart:convert';
import 'dart:io';

import 'tag.dart';

// dart /Users/herveguigoz/dev/dart/dashlog/bin/dashlog.dart
// https://github.com/erickzanardo/dashmon/blob/main/lib/src/dashmon.dart
class Dashlog {
  Dashlog(this.args);

  final List<String> args;

  Future<void> start() async {
    final tag = await getTags();
    print(tag.length);
    exit(1);
  }

  static Future<List<String>> runCommand(
    String executable,
    List<String> arguments,
  ) async {
    final _process = await Process.start(executable, arguments);
    final result = await _process.stdout.transform(utf8.decoder).first;
    _process.kill();
    return LineSplitter().convert(result);
  }
}

import 'dart:convert';
import 'dart:io';

import 'commit.dart';
import 'tag.dart';

// dart /Users/herveguigoz/dev/dart/dashlog/bin/dashlog.dart
// https://github.com/erickzanardo/dashmon/blob/main/lib/src/dashmon.dart
class Dashlog {
  Dashlog(this.args);

  final List<String> args;

  Future<void> start() async {
    final tags = await getTags();
    final commits = await getCommits(start: tags.first, end: tags[1]);
    commits.forEach(print);
    exit(1);
  }

  static Future<List<String>> runCommand(
    String executable,
    List<String> arguments,
  ) async {
    final _process = await Process.start(executable, arguments);
    final res = await _process.stdout.transform(utf8.decoder).first;
    _process.kill();
    return LineSplitter().convert(res).map((line) => line.sanitilize).toList();
  }
}

extension on String {
  String get sanitilize => replaceAll("'", '').trim();
}

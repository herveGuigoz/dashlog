import 'dart:convert';
import 'dart:io';

// dart /Users/herveguigoz/dev/dart/dashlog/bin/dashlog.dart
// https://github.com/erickzanardo/dashmon/blob/main/lib/src/dashmon.dart
class Dashlog {
  Dashlog(this.args);

  final List<String> args;

  Future<void> start() async {
    final tags = await getTags();
    print(tags);
    exit(1);
  }

  Future<List<String>> getTags() async => _process('git', ['tag', '-l']);

  Future<List<String>> _process(
    String executable,
    List<String> arguments,
  ) async {
    final result = <String>[];
    final _process = await Process.start(executable, arguments);
    await _process.stdout.transform(utf8.decoder).forEach(result.add);
    _process.kill();
    return result;
  }
}

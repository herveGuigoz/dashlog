import 'dart:convert';
import 'dart:io';

import 'commit.dart';
import 'tag.dart';
import 'render.dart';

const _kOutputFile = 'CHANGELOG.md';

// dart /Users/herveguigoz/dev/dart/dashlog/bin/dashlog.dart
class Dashlog {
  Dashlog(this.args);

  /// String output file (default to CHANGELOG.md)
  /// bool semantic (default to true)
  /// List<String> semantic patterns to ignore
  /// DateTime? after
  final List<String> args;

  /// Return current directory
  String get pwd => Platform.environment['PWD'] as String;

  Future<void> start() async {
    final tags = await getTags();

    final file = File(_kOutputFile).openWrite(mode: FileMode.write);
    file.writeln('# CHANGELOG \n');

    for (var i = 0; i < tags.length - 1; i++) {
      final commits = await getCommits(start: tags[i], end: tags[i + 1]);

      // if commits dont match Conventional Commits we ignore them.
      // https://www.conventionalcommits.org/en/v1.0.0/
      if (commits.isEmpty) continue;

      final output = render({
        'tags': [
          {
            'version': tags[i].version,
            'date': tags[i].date.ddMMyyyy,
            'commits': [
              for (final commit in commits)
                {'type': commit.type, 'name': commit.name},
            ],
          },
        ],
      });
      file.writeln(output);
    }

    await file.close();

    await _flushThenExit(0);
  }
}

Future<List<String>> runCommand(
  String executable,
  List<String> arguments,
) async {
  final _process = await Process.start(executable, arguments);
  // TODO add onError to this future
  final res = await _process.stdout.transform(utf8.decoder).first;
  _process.kill();
  return LineSplitter().convert(res).map((line) => line.sanitize).toList();
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future _flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}

extension on String {
  String get sanitize => replaceAll("'", '').trim();
}

extension on DateTime {
  String get ddMMyyyy {
    return '${day > 9 ? day : '0$day'}-${month > 9 ? month : '0$month'}-$year';
  }
}

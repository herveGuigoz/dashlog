import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'commit.dart';
import 'tag.dart';
import 'render.dart';

const _kOutputFile = 'CHANGELOG.md';
const kPatterns = ['feat', 'fix', 'test', 'docs', 'build'];

class Dashlog extends CommandRunner<int> {
  Dashlog() : super('dashlog', 'Command line tool for generating a changelog') {
    addCommand(CreateCommand());
  }

  /// Return current directory
  String get pwd => Platform.environment['PWD'] as String;

  @override
  Future<int> run(Iterable<String> args) async {
    final _argResults = parse(args);
    return await runCommand(_argResults) ?? 0;
  }
}

class CreateCommand extends Command<int> {
  CreateCommand() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output path',
        valueHelp: 'path',
        defaultsTo: _kOutputFile,
      )
      ..addMultiOption(
        'types',
        abbr: 't',
        help: 'Commits types (other types will be ignored)',
        valueHelp: 'patterns separated by comma',
        defaultsTo: kPatterns,
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Generate changelog file';

  String get outputFile {
    return argResults!['output'] as String? ?? _kOutputFile;
  }

  List<String> get patterns {
    return argResults!['patterns'] as List<String>? ?? kPatterns;
  }

  /// Translate patterns to regex that match fancy icons. ex '👌 fix'
  String get paternsToRegex {
    return patterns.reduce((value, element) => '$value|$element');
  }

  @override
  Future<int> run() async {
    final tags = await getTags();
    final file = File(outputFile).openWrite(mode: FileMode.write);
    file.writeln('# CHANGELOG \n');

    for (var i = 0; i < tags.length - 1; i++) {
      final commits = await getCommits(start: tags[i], end: tags[i + 1]);

      // if commits dont match Conventional Commits patterns we ignore them.
      commits.removeWhere(
        (commit) => !RegExp(paternsToRegex).hasMatch(commit.type),
      );
      if (commits.isEmpty) continue;

      final output = render({
        'tags': [
          {
            'version': tags[i].version,
            'date': tags[i].date.ddMMyyyy,
            'commits': [
              for (final commit in commits)
                {'type': commit.type, 'description': commit.description},
            ],
          },
        ],
      });
      file.writeln(output);
    }

    await file.close();

    return 0;
  }
}

Future<List<String>> shell(
  String executable,
  List<String> arguments,
) async {
  final _process = await Process.start(executable, arguments);
  final res = await _process.stdout.transform(utf8.decoder).first;
  _process.kill();
  return LineSplitter().convert(res).map((line) => line.sanitize).toList();
}

extension on String {
  String get sanitize => replaceAll("'", '').trim();
}

extension on DateTime {
  String get ddMMyyyy {
    return '${day > 9 ? day : '0$day'}-${month > 9 ? month : '0$month'}-$year';
  }
}

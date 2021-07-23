import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'commit.dart';
import 'logger.dart';
import 'render.dart';
import 'tag.dart';
import 'version.dart';

const _kOutputFile = 'CHANGELOG.md';
const kPatterns = ['feat', 'fix', 'test', 'docs', 'build'];

class Dashlog extends CommandRunner<int> {
  Dashlog() : super('dashlog', 'Command line tool for generating a changelog') {
    argParser.addFlag('version', help: 'current version', negatable: false);
    addCommand(CreateCommand());
  }

  /// Return current directory
  String get pwd => Platform.environment['PWD'] as String;

  @override
  Future<int> run(Iterable<String> args) async {
    final _argResults = parse(args);
    return await runCommand(_argResults) ?? 0;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      print(packageVersion); // add logger
      return 0;
    }

    return super.runCommand(topLevelResults);
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
    return argResults!['types'] as List<String>? ?? kPatterns;
  }

  /// Translate patterns to regex that match fancy icons. ex '👌 fix'
  String get paternsToRegex {
    return patterns.reduce((value, element) => '$value|$element');
  }

  @override
  Future<int> run() async {
    try {
      final tags = await getTags();
      final file = File(outputFile).openWrite(mode: FileMode.write);
      file.writeln('# CHANGELOG \n');

      for (var i = 0; i < tags.length; i++) {
        final isLastTag = tags.last.hash == tags[i].hash;
        final commits = await getCommits(
          start: tags[i],
          end: isLastTag ? null : tags[i + 1],
        );

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

      Logger.success('$outputFile was created');
      return 0;
    } on ShellException catch (e) {
      Logger.error(e.toString());
      return 1;
    }
  }
}

Future<List<String>> shell(String executable, List<String> arguments) async {
  try {
    final _process = await Process.start(executable, arguments);
    final res = await _process.stdout.transform(utf8.decoder).first;
    _process.kill();
    return LineSplitter().convert(res).map((line) => line.sanitize).toList();
  } catch (_) {
    throw ShellException();
  }
}

extension on String {
  String get sanitize => replaceAll("'", '').trim();
}

extension on DateTime {
  String get ddMMyyyy {
    return '${day > 9 ? day : '0$day'}-${month > 9 ? month : '0$month'}-$year';
  }
}

class ShellException implements Exception {
  @override
  String toString() => 'Error: Not a git repository';
}

import 'package:dashlog/src/tag.dart';

import 'dashlog.dart';

class Commit extends Comparable<Commit> {
  Commit._(this.hash, this.type, this.name);

  final String hash;
  final String type;
  final String name;

  @override
  int compareTo(Commit other) => type.compareTo(other.type);

  @override
  String toString() => 'Commit(hash: $hash, type: $type, name: $name)';
}

/// Get list of tag.
Future<List<Commit>> getCommits({required Tag start, required Tag end}) async {
  final lines = await runCommand(
    'git',
    ['log', '${start.hash}...${end.hash}', '-E', '--format=%H;%s;'],
  );

  return _parseCommits(lines);
}

/// Cast list of [String] to list of [Commit]
List<Commit> _parseCommits(List<String> lines) {
  final commits = <Commit>[];
  final regex = RegExp(r'^(.+);(.+):(.+);');

  for (final line in lines) {
    final matches = regex.firstMatch(line);
    if (matches != null && matches.groupCount == 3) {
      commits.add(
        Commit._(matches.group(1)!, matches.group(2)!, matches.group(3)!),
      );
    }
  }

  return commits..sort();
}

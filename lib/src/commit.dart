import 'package:dashlog/src/tag.dart';

import 'dashlog.dart';

/// A representation of a parsed conventional commit message.
class Commit extends Comparable<Commit> {
  Commit._(this.hash, this.type, this.description);

  final String hash;
  final String type;
  final String description;

  @override
  int compareTo(Commit other) => type.compareTo(other.type);

  @override
  String toString() => 'Commit($hash $type: $description)';
}

/// Get list of [Commit] between two tags.
Future<List<Commit>> getCommits({required Tag start, Tag? end}) async {
  final hashs = end != null ? '${start.hash}...${end.hash}' : start.hash;
  final lines = await shell('git log $hashs --format="%H;%s;"');

  return _parseCommits(lines);
}

/// Cast list of [String] to list of [Commit]
List<Commit> _parseCommits(Iterable<String> lines) {
  final commits = <Commit>[];
  final regex = RegExp(r'^(?<hash>.+);(?<type>.+):(?<description>.+);');

  for (final line in lines) {
    final matches = regex.firstMatch(line);
    if (matches != null && matches.groupCount == 3) {
      commits.add(
        Commit._(
          matches.namedGroup('hash')!,
          matches.namedGroup('type')!,
          matches.namedGroup('description')!,
        ),
      );
    }
  }

  return commits..sort();
}

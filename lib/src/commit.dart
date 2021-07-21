// git log 2861f87602c0ccbe55cb595e7c485459185a8766...5c4242d55cc0880a710ead4f213ed0817d0ae532 --oneline --pretty="%h%s"

import 'package:dashlog/src/tag.dart';

import '../dashlog.dart';

// TODO Date
class Commit {
  const Commit._(this.hash, this.type, this.name);

  final String hash;
  final String type;
  final String name;

  @override
  String toString() => 'Commit(hash: $hash, type: $type, name: $name)';
}

/// Get list of tag.
Future<List<Commit>> getCommits({required Tag start, required Tag end}) async {
  final lines = await Dashlog.runCommand(
    'git',
    ['log', '${start.hash}...${end.hash}', '-E', '--format=%H;%s;'],
  );

  return _parseCommits(lines);
}

/// Parse [String] to [Commit]
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

  return commits;
}

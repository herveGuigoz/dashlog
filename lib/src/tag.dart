import 'dashlog.dart';

/// A representation of a parsed tag message.
class Tag extends Comparable<Tag> {
  Tag._(this.version, this.hash, this.date);

  final String version;
  final String hash;
  final DateTime date;

  @override
  int compareTo(other) => other.date.compareTo(date);

  @override
  String toString() => 'Tag(version: $version, hash: $hash, date: $date)';
}

/// Get list of tag.
Future<List<Tag>> getTags() async {
  final lines = await shell(
    'git',
    ['log', '--no-walk', '--tags', "--pretty='%d;%H;%ci'", '--decorate=short'],
  );

  return _parseTags(lines);
}

/// Get most recent tag.
Future<Tag> getLastTag() async => getTags().then((tags) => tags.first);

/// Cast list of [String] to list of [Tag]
List<Tag> _parseTags(List<String> lines) {
  final tags = <Tag>[];
  final tagRegex = RegExp(r'tag:\s*([^,)]+)');
  final lineRegex = RegExp(r'^(?<version>.+);(?<hash>.+);(?<date>.+)$');

  for (final line in lines) {
    final matches = lineRegex.firstMatch(line);
    if (matches != null && matches.groupCount == 3) {
      // Check if version is well formatted
      final version = tagRegex.firstMatch(matches.namedGroup('version')!);
      if (version == null) continue;

      tags.add(Tag._(
        version.group(1)!,
        matches.namedGroup('hash')!,
        DateTime.parse(matches.namedGroup('date')!),
      ));
    }
  }

  return tags..sort();
}

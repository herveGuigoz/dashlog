import '../dashlog.dart';

class Tag extends Comparable {
  Tag._(this.version, this.hash, this.date);

  final String version;
  final String hash;
  final DateTime date;

  @override
  int compareTo(other) => date.compareTo(other);

  @override
  String toString() => 'Tag(version: $version, hash: $hash, date: $date)';
}

/// Get list of tag.
Future<List<Tag>> getTags() async {
  final lines = await Dashlog.runCommand(
    'git',
    ['log', '--no-walk', '--tags', "--pretty='%d;%H;%ci'", '--decorate=short'],
  );

  return _parseTags(lines);
}

/// Get most recent tag.
Future<Tag> getLastVersion() async => getTags().then((tags) => tags.first);

/// Parse [String] to [Tag]
List<Tag> _parseTags(List<String> lines) {
  final tags = <Tag>[];
  final tagRegex = RegExp(r'tag:\s*([^,)]+)');
  final lineRegex = RegExp(r'^(.+);(.+);(.+)$');

  for (final line in lines) {
    final matches = lineRegex.firstMatch(line);
    if (matches != null && matches.groupCount == 3) {
      // Check if version is well formatted
      final version = tagRegex.firstMatch(matches.group(1)!);
      if (version == null) continue;

      tags.add(Tag._(
        version.group(1)!,
        matches.group(2)!,
        DateTime.parse(matches.group(3)!),
      ));
    }
  }

  return tags;
}

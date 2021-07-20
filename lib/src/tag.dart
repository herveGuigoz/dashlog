import '../dashlog.dart';

// https://github.com/ikhemissi/tagged-versions/blob/master/src/index.js

const _tagRegex = r'tag:\s*([^,)]+)';
final _lineRegex = RegExp(r'^(.+);(.+);(.+)$');

/// Get list of tag.
Future<List<Tag>> getTags() async {
  return Dashlog.runCommand(
    'git',
    ['log', '--no-walk', '--tags', "--pretty='%d;%H;%ci'", '--decorate=short'],
  ).then((tags) => tags.lines.map((tag) => Tag._(tag)).toList());
}

/// Get most recent tag.
Future<Tag> getLastVersion() async => getTags().then((tags) => tags.first);

class Tag extends Comparable {
  Tag._(String value)
      : version = RegExp(_tagRegex).firstMatch(value.tag).group(1),
        hash = value.hash,
        date = value.date;

  final String version;
  final String hash;
  final DateTime date;

  @override
  int compareTo(other) => date.compareTo(other);

  @override
  String toString() => 'Tag(version: $version, hash: $hash, date: $date)';
}

extension on List<String> {
  /// Filter command outputs for lines that satisfy semantic version name.
  Iterable<String> get lines {
    return where(
      (line) =>
          _lineRegex.hasMatch(line) &&
          _lineRegex.firstMatch(line).groupCount == 3 &&
          RegExp(_tagRegex).hasMatch(_lineRegex.firstMatch(line).group(1)),
    );
  }
}

extension on String {
  String get sanitilize => replaceAll("'", '').trim();

  RegExpMatch get semanticCommits => _lineRegex.firstMatch(sanitilize);
  String get tag => semanticCommits.group(1);
  String get hash => semanticCommits.group(2);
  DateTime get date => DateTime.parse(semanticCommits.group(3));
}

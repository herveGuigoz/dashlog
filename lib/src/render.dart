import 'package:mustache_template/mustache.dart';

/// Given a Map of String key / value pairs, substitute all instances of
/// `{{key}}` for `value`.
/// ```dart
/// final output = render(
///   {
///     'tags': [
///       {
///         'version': 'v0.0.1',
///         'date': '21-01-1988',
///         'commits': [
///           {'type': 'Fix', 'name': 'Big fix'},
///           {'type': 'Feature', 'name': 'Amazing feature'},
///           {'type': 'Test', 'name': 'Tests on last fixes'},
///         ]
///       }
///     ]
///   },
/// );
/// ```
String render(
  dynamic values, [
  PartialResolver? partialResolver,
]) {
  final template = Template(
    kTemplate,
    lenient: true,
    partialResolver: partialResolver,
  );

  return template.renderString(values);
}

/// Default template source
/// https://mustache.github.io/mustache.5.html
const kTemplate = '''
{{ #tags }}
## {{ version }}
> {{ date }}

{{ #commits }}
* {{ type }}: {{ name }}
{{ /commits }}
{{ /tags }}
''';

import 'dart:io';

class Logger {
  /// Ansi green color
  static String get _green => '\u001b[32m';

  /// Ansi red color
  static String get _red => '\u001b[31m';

  /// Print an error message.
  static void error(String message) => stderr.writeln('$_red$message');

  /// Print an success message.
  static void success(String message) => stdout.writeln('$_green$message');
}

import 'dart:io';

import 'package:dashlog/dashlog.dart';

Future<void> main(List<String> arguments) async {
  exit(await Dashlog().run(arguments));
}

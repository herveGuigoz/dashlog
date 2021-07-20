import 'package:dashlog/dashlog.dart';

void main(List<String> arguments) {
  final dashmon = Dashlog(arguments);
  dashmon.start();
}

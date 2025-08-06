import 'package:logger/web.dart';

class LoggerManager {
  static final log = Logger(
    printer: PrettyPrinter()
  );
}
import 'package:logger/logger.dart';

class LoggerManager {
  static final log = Logger(
    printer: PrettyPrinter()
  );
}
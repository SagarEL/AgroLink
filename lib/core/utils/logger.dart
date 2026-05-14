import 'package:logger/logger.dart';

/// Single shared logger. Use `appLog.d/i/w/e` instead of print.
final Logger appLog = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 6,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

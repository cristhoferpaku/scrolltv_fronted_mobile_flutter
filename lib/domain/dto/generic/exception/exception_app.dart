import 'package:freezed_annotation/freezed_annotation.dart';
part 'exception_app.freezed.dart';
part 'exception_app.g.dart';

@freezed
abstract class ExceptionApp with _$ExceptionApp {
  factory ExceptionApp(int statusCode, String message) = _ExceptionApp;

  factory ExceptionApp.fromJson(Map<String, dynamic> json) =>
      _$ExceptionAppFromJson(json);
}

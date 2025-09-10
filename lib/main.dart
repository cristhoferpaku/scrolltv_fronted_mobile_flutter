import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppModule();

  final locale = WidgetsBinding.instance.window.locale.toLanguageTag();
  Intl.defaultLocale = locale;

  final userRepo = instance<UserRepository>();

  const bool isTv = bool.fromEnvironment('IS_TV', defaultValue: false);
  const String variant = String.fromEnvironment('VARIANT', defaultValue: 'not_set');

  runApp(MyApp(
    logUser: await userRepo.isUserLogged(),
  ));
}

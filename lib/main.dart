import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppModule();

  final userRepo = instance<UserRepository>();

  runApp(MyApp(
    logUser: await userRepo.isUserLogged(),
  ));
}

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/my_app.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();

  await initAppModule();
  runApp(const MyApp( logUser: false,));
}


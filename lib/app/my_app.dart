import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/l10n/l10n.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/string_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/theme_manager.dart';

class MyApp extends StatefulWidget {
  final bool logUser; 

  const MyApp(
      {super.key,
      required this.logUser,});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String initialRouteApp;

  @override
  void initState() {
    super.initState();
    initialRouteApp = getRouteByUserLogged(
      // widget.logUser,
      // widget.idCompany,
      // widget.nameCompany,
      // widget.idProject,
      // widget.nameProject,
    );
  }

  @override
  Widget build(BuildContext context) {
    initContext(context);
    return MaterialApp(
      title: AppString.headerTitle, // for web title
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: initialRouteApp,
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      darkTheme: getApplicationDarkTheme(),
      supportedLocales: L10n.all,
    );
  }

  String getRouteByUserLogged(){
    return Routes.loginRoute;
  //   bool logUser,
  //   String? idCompany,
  //   String? nameCompany,
  //   String? idProject,
  //   String? nameProject,
  // ) {
  //   if (!logUser) {
  //     // Si el usuario no está logueado, redirigir a login
  //     return Routes.loginRoute;
  //   } else if ((idCompany == null || idCompany.isEmpty) &&
  //       (nameCompany == null || nameCompany.isEmpty)) {
  //     return Routes.associatedCompaniesRoute;
  //   } else if ((idProject == null || idProject.isEmpty) &&
  //       (idCompany == null || idCompany.isEmpty)) {
  //     return Routes.associatedCompaniesRoute;
  //   } else if ((idProject == null || idProject.isEmpty) &&
  //       (idCompany != null && idCompany.isNotEmpty)) {
  //     return Routes.associatedCompaniesRoute;
  //   } else {
  //     return Routes.homeRoute;
  //   }
  // }
  }
}

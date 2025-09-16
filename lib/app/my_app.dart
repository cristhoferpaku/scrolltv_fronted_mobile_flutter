import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/l10n/l10n.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/utils/utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_listener.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/string_manager.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool logUser;

  const MyApp({
    super.key,
    required this.logUser,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String initialRouteApp;
  final AuthBloc authBloc = instance<AuthBloc>();

  @override
  void initState() {
    super.initState();
    initialRouteApp = getRouteByUserLogged(
      widget.logUser,
    );
  }

  final bool isTv = PlatformUtils.isTV;

  @override
  Widget build(BuildContext context) {
    initContext(context);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        navigatorKey: navigatorKey,
        title: AppString.headerTitle, // for web title
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: initialRouteApp,
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme(isTv),
        supportedLocales: L10n.all,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorObservers: [routeObserver],
        builder: (context, child) {
          // Aquí el context YA tiene acceso a MaterialLocalizations
          return BlocListener<AuthBloc, AuthState>(
            bloc: authBloc,
            listener: (context, state) => authListener(context, state, authBloc),
            child: child,
          );
        },
      ),
    );
  }

  String getRouteByUserLogged(bool logUser) {
    if (!logUser) {
      return Routes.inicioRoute;
    } else {
      return Routes.homeRoute;
    }
  }
}

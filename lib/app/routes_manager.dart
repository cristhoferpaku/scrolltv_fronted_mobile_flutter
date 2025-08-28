import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/components/pages/colors_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/components/pages/typography_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/live_tv_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/mobile/components_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/mobile/mobile.dart' as mobile;
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/home_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/profile_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/terms_and_conditions_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/video_details_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/video_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/tv/tv.dart' as tv;
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/string_manager.dart';

class Routes {
  //static const String splashRoute = '/';
  static const String loginRoute = 'login';
  static const String principalRoute = 'principal';

  static const String homeRoute = 'home';
  static const String mobileHomeRoute = 'mobileHome';
  static const String componentsRoute = 'components';

  static const String typographyRoute = 'typography';
  static const String colorsRoute = 'colors';

  static const String inicioRoute = 'inicio';
  static const String liveTvRoute = 'liveTv';
  static const String profileRoute = 'profile';
  static const String termsAndConditionsRoute = 'termsAndConditions';
  static const String videoRoute = 'video';
  static const String videoDetailsRoute = 'videoDetails';
}

class RouteGenerator {
  static bool isTv = PlatformUtils.isTV;
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.loginRoute:
        //initLoginDependencies();
        return MaterialPageRoute(builder: (_) => isTv ? const tv.LoginPage() : const mobile.LoginPage());

      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case Routes.componentsRoute:
        return MaterialPageRoute(builder: (_) => const ComponentsPage());

      case Routes.typographyRoute:
        return MaterialPageRoute(builder: (_) => const TypographyPage());

      case Routes.colorsRoute:
        return MaterialPageRoute(builder: (_) => const ColorsPage());

      case Routes.liveTvRoute:
        return MaterialPageRoute(builder: (_) => const LiveTvDetail());

      case Routes.inicioRoute:
        return MaterialPageRoute(builder: (_) => isTv ? const tv.InicioPage() : const mobile.InicioPage());

      case Routes.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case Routes.videoRoute:
        return MaterialPageRoute(builder: (_) => const VideoPage());

      case Routes.videoDetailsRoute:
        return MaterialPageRoute(builder: (_) => const VideoDetailsPage(), settings: RouteSettings(name: Routes.videoDetailsRoute, arguments: routeSettings.arguments));

      case Routes.termsAndConditionsRoute:
        return MaterialPageRoute(builder: (_) => const TermsAndConditionsPage());

      // case Routes.drawerRoute:
      //   initDrawerDependencies();
      //   return MaterialPageRoute(builder: (_) => const DrawerPage());

      // return MaterialPageRoute(
      //     builder: (_) => const NoAssociatedProjectPage());
      // return MaterialPageRoute(
      //   //child: const NotificationsPage(),
      // );

      //initNextPaimentDependencies();
      // final int? id = routeSettings.arguments as int?;
      // if (id == null) {
      //   return unDefinedRoute();
      // }
      // return CustomAnimationPageTransitionFadeSlide(
      //   child: DetailNextPaimentPage(
      //     id: id,
      //   ),
      // )

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(title: const Text(AppString.noRouteFound)),
              body: const Center(child: Text(AppString.noRouteFound)),
            ));
  }
}

class TemplateForAnimationBase extends PageRouteBuilder {
  final Widget child;

  TemplateForAnimationBase({
    required this.child,
  }) : super(transitionDuration: const Duration(milliseconds: 400), pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(scale: animation, child: child);
  }
}

class CustomAnimationPageTransitionFadeSlide extends PageRouteBuilder {
  final Widget child;
  final RouteSettings? routeSettings;

  CustomAnimationPageTransitionFadeSlide({required this.child, this.routeSettings})
      : super(transitionDuration: const Duration(milliseconds: 500), pageBuilder: (context, animation, secondaryAnimation) => child, settings: routeSettings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // ScaleTransition(scale: animation, child: child);
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Slide in from the right
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }
}

class AnimationRouteTransitionBelow extends PageRouteBuilder {
  final Widget child;
  final RouteSettings? settingsRoute;

  AnimationRouteTransitionBelow({required this.child, this.settingsRoute})
      : super(transitionDuration: const Duration(milliseconds: 300), pageBuilder: (context, animation, secondaryAnimation) => child, settings: settingsRoute);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }
}

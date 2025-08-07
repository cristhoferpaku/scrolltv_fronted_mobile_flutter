import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';

class Component {
  final String name;
  final String route;

  Component({required this.name, required this.route});
}

final List<Component> componentsData = [
  Component(name: "Tipografia", route: Routes.typographyRoute),
  Component(name: "Colores", route: Routes.colorsRoute),
  // Component(name: "Inputs", route: Routes.typographyRoute),
  // Component(name: "Cards", route: Routes.typographyRoute),
];

import 'package:envied/envied.dart';

// Run 'flutter pub run build_runner build' to generate env.g.dart
part 'env.g.dart';

@Envied(path: '.env', useConstantCase: true, obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'PROJECT_NAME')
  static String projectName = _Env.projectName;
  @EnviedField(varName: 'ENVIRONMENT')
  static String environment = _Env.environment;
  @EnviedField(varName: 'API_URL')
  static String baseApiUrl = _Env.baseApiUrl;
}

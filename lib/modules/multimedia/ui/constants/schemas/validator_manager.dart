class ValidatorManager {
  static String? validateUsername(String value) {
    if (value.isEmpty) {
      return 'El campo usuario es requerido';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'El campo contraseña es requerido';
    }
    return null;
  }
}

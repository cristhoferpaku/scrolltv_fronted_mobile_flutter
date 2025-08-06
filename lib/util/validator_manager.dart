import 'package:scrolltv_frontend_mobile_flutter/util/string_manager.dart';

class UtilFunctions {
  bool isEmail(String email) {
    final trimmed = email.trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(trimmed);
  }

  bool validatePassword(String pass) {
    return pass.length < 6;
  }

  String? validatorSimplePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppString.loginFieldErrorPassword;
    }
    return null;
  }

  String? validatorPassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppString.loginFieldErrorPassword;
    } else if (!getComplexPassUpperCase(password)) {
      return AppString.loginFieldComplexPasswordUpperCase;
    } else if (!getComplexPassLowerCase(password)) {
      return AppString.loginFieldComplexPasswordLowerCase;
    } else if (!getComplexPassNumber(password)) {
      return AppString.loginFieldComplexPasswordNumber;
    } else if (!getComplexSymbol(password)) {
      return AppString.loginFieldComplexPasswordSymbol;
    } else if (password.length <= 8) {
      return AppString.loginFieldComplexPasswordSize;
    } else {
      return null;
    }
  }

  String? validatorUserName(String? userName) {
    if (userName == null || userName.isEmpty) {
      return AppString.signUpPageNameUserPlaceHolder;
    } else if (userName.length <= 5) {
      return AppString.signUpPageValidatorLenghtName;
    } else if (getComplexSymbol(userName)) {
      return AppString.signUpPageValidatorSymbolName;
    } else {
      return null;
    }
  }

  String? validatorUsernameOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppString.loginFieldErrorEmail; // o texto genérico si deseas
    }

    if (isEmail(value)) {
      return validatorEmail(value);
    } else {
      return validatorUserName(value);
    }
  }

  String? validatorEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AppString.loginFieldErrorEmail;
    } else if (isEmail(email)) {
      return null;
    } else {
      return AppString.loginFieldErrorEmail;
    }
  }

  String? validatorPinCode(String? pinCode, int lenghtCode) {
    if (pinCode?.length == 6) {
      return null;
    } else {
      return AppString.forgotFieldPinCodedLimit;
    }
  }

  String? validatorReNewPassword(String? password, String previousPassword) {
    if (password == null || password.isEmpty) {
      return AppString.loginFieldErrorPassword;
    } else if (password != previousPassword) {
      return AppString.forgotPageFieldSamePassword;
    } else {
      return null;
    }
  }

  bool getComplexPassUpperCase(String pass) {
    //(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$
    var pattern = r'^(?=.*?[A-Z])';
    var regExp = RegExp(pattern);
    return regExp.hasMatch(pass);
  }

  bool getComplexPassLowerCase(String pass) {
    //(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$
    var pattern = r'^(?=.*?[a-z])';
    var regExp = RegExp(pattern);
    return regExp.hasMatch(pass);
  }

  bool getComplexPassNumber(String pass) {
    //(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$
    var pattern = r'^(?=.*?[0-9])';
    var regExp = RegExp(pattern);
    return regExp.hasMatch(pass);
  }

  bool getComplexSymbol(String pass) {
    //(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$
    var pattern = r'^(?=.*?[!@#\$&*~])';
    var regExp = RegExp(pattern);
    return regExp.hasMatch(pass);
  }
}

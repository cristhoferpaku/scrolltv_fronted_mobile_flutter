
import 'package:scrolltv_frontend_mobile_flutter/app/constants.dart';

extension NonNullString on String? {
  String orEmpty(){
    if(this == null){
      return empty;
    } else {
      return this!;
    }
  }
}

// Extensions from Integer
extension NonNullInteger on int? {
  int orEmpty(){
    if(this == null){
      return zero;
    } else {
      return this!;
    }
  }
}

extension ValidatorEmail on String {
  bool isEmail() {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);
  }
}
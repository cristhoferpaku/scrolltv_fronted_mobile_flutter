import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';

void homeListener(BuildContext context, HomeState state) {
  if (state is HomeStateLoaded) {
    if (state.status == HomeStateStatus.errorServiceExpired) {}
  }
}

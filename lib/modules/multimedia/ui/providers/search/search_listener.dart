import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

void searchListener(BuildContext context, SearchState state) {
  final isTV = PlatformUtils.isTV;
  if (state is SearchStateLoaded) {
    if (state.status == SearchStateStatus.loadedVideos) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isTV && state.search.isNotEmpty) {
          FocusScope.of(context).nextFocus();
        }
      });
    }
  }
}

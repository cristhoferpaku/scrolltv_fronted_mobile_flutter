import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_tab_bar_bloc.freezed.dart';
part 'custom_tab_bar_event.dart';
part 'custom_tab_bar_state.dart';

class CustomTabBarBloc extends Bloc<CustomTabBarEvent, CustomTabBarState> {
  CustomTabBarBloc() : super(const _Initial()) {
    int currentIndex = 0;
    on<CustomTabBarEvent>((event, emit) {});
    on<_CustomTabBarEventStarted>((event, emit) {
      emit(CustomTabBarState.loaded(currentIndex));
    });
    on<_CustomTabBarEventChangeTab>((event, emit) {
      currentIndex = event.index;
      emit(CustomTabBarState.loaded(currentIndex));
    });
  }
}

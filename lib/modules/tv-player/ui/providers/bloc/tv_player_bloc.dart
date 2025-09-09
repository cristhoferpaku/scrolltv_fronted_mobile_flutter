import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/ports/inbound/tv_player_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/constants/focus_enum.dart';

part 'tv_player_bloc.freezed.dart';
part 'tv_player_event.dart';
part 'tv_player_state.dart';

class TvPlayerBloc extends Bloc<TvPlayerEvent, TvPlayerState> {
  TvPlayerBloc()
      : super(TvPlayerState(
          status: TVPlayerStatus.initial,
          channels: [],
          selectedChannelIndex: null,
          showChannelList: false,
          selectedCategoryIndex: 0,
          focusEnum: FocusEnum.channelView,
          categories: [],
          allChannels: [],
        )) {
    TvPlayerUseCase tvPlayerUseCase = instance<TvPlayerUseCase>();
    ChannelModel? selectedChannelIndex;
    int selectedCategoryIndex = 0;
    bool showChannelList = false;
    FocusEnum focusEnum = FocusEnum.channelView;
    List<ChannelModel> allChannels = [];
    List<ChannelModel> channels = [];
    List<ChannelCategoryModel> categories = [];
    on<TvPlayerEvent>((event, emit) {});
    on<_TVPlayerEventStarted>((event, emit) async {
      add(_TVPlayerEventLoadChannels());
    });

    on<_TVPlayerEventLoadChannels>((event, emit) async {
      final channelsResponse = await tvPlayerUseCase.getChannels();
      allChannels = channelsResponse.data;
      channels = channelsResponse.data;
      emit(state.copyWith(status: TVPlayerStatus.loadedChannels, channels: channels, allChannels: allChannels));
      add(_TVPlayerEventLoadCategories());
    });
    on<_TVPlayerEventLoadCategories>((event, emit) async {
      categories = tvPlayerUseCase.getCategories(channels);
      emit(state.copyWith(status: TVPlayerStatus.loadedCategories, categories: categories));
    });
    on<_TVPlayerEventChangeChannel>((event, emit) {
      selectedChannelIndex = event.channelIndex;
      emit(state.copyWith(selectedChannelIndex: selectedChannelIndex, showChannelList: showChannelList, selectedCategoryIndex: selectedCategoryIndex, focusEnum: focusEnum));
    });
    on<_TVPlayerEventShowPanelChannel>((event, emit) {
      showChannelList = event.value;
      emit(state.copyWith(showChannelList: showChannelList, selectedCategoryIndex: selectedCategoryIndex, focusEnum: focusEnum));
    });
    on<_TVPlayerEventChangeCategory>((event, emit) {
      selectedCategoryIndex = event.categoryIndex;
      channels = tvPlayerUseCase.getChannelsByCategory(allChannels, categories[selectedCategoryIndex].name);
      emit(state.copyWith(selectedCategoryIndex: selectedCategoryIndex, showChannelList: showChannelList, focusEnum: focusEnum, channels: channels));
    });
    on<_TVPlayerEventChangeFocus>((event, emit) {
      focusEnum = event.focusEnum;
      emit(state.copyWith(focusEnum: focusEnum));
    });
  }
}

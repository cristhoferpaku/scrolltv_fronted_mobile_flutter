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
      // final channelsResponse = [];
      // allChannels = ;
      // channels = channelsResponse;

      emit(TvPlayerState(
          status: TVPlayerStatus.loadedChannels,
          channels: channels,
          allChannels: allChannels,
          selectedChannelIndex: selectedChannelIndex,
          showChannelList: showChannelList,
          selectedCategoryIndex: selectedCategoryIndex,
          focusEnum: focusEnum,
          categories: categories));
      add(_TVPlayerEventLoadCategories());
    });
    on<_TVPlayerEventLoadCategories>((event, emit) async {
      final categoriesResponse = await tvPlayerUseCase.getCategories();
      categories = categoriesResponse.data;
      emit(TvPlayerState(
          status: TVPlayerStatus.loadedCategories,
          categories: categories,
          channels: channels,
          selectedChannelIndex: selectedChannelIndex,
          showChannelList: showChannelList,
          selectedCategoryIndex: selectedCategoryIndex,
          focusEnum: focusEnum,
          allChannels: allChannels));

      if (categories.isNotEmpty) {
        add(_TVPlayerEventLoadChannelsByCategory(categories[selectedCategoryIndex]));
      }
    });
    on<_TVPlayerEventChangeChannel>((event, emit) {
      selectedChannelIndex = event.channelIndex;
      emit(TvPlayerState(
          status: TVPlayerStatus.changeChannelSuccess,
          selectedChannelIndex: selectedChannelIndex,
          showChannelList: showChannelList,
          selectedCategoryIndex: selectedCategoryIndex,
          focusEnum: focusEnum,
          channels: channels,
          allChannels: allChannels,
          categories: categories));
    });
    on<_TVPlayerEventShowPanelChannel>((event, emit) {
      showChannelList = event.value;
      if (!showChannelList) {
        focusEnum = FocusEnum.channelView;
      } else {
        focusEnum = FocusEnum.channelList;
      }
      emit(TvPlayerState(
          status: TVPlayerStatus.loaded,
          selectedChannelIndex: selectedChannelIndex,
          showChannelList: showChannelList,
          selectedCategoryIndex: selectedCategoryIndex,
          focusEnum: focusEnum,
          channels: channels,
          allChannels: allChannels,
          categories: categories));
    });
    on<_TVPlayerEventChangeCategory>((event, emit) async {
      selectedCategoryIndex = event.categoryIndex;
      emit(TvPlayerState(
          status: TVPlayerStatus.changeCategorySuccess,
          selectedCategoryIndex: selectedCategoryIndex,
          showChannelList: showChannelList,
          focusEnum: focusEnum,
          channels: channels,
          allChannels: allChannels,
          categories: categories,
          selectedChannelIndex: selectedChannelIndex));
      add(_TVPlayerEventLoadChannelsByCategory(categories[selectedCategoryIndex]));
    });
    on<_TVPlayerEventLoadChannelsByCategory>((event, emit) async {
      final channelsResponse = await tvPlayerUseCase.getChannelsByCategory(event.category);

      channels = channelsResponse.data;

      if (selectedChannelIndex == null) {
        add(_TVPlayerEventChangeChannel(channels.first));
      }
      emit(TvPlayerState(
          status: TVPlayerStatus.loadedChannelsByCategory,
          selectedCategoryIndex: selectedCategoryIndex,
          showChannelList: showChannelList,
          focusEnum: focusEnum,
          channels: channels,
          allChannels: allChannels,
          categories: categories,
          selectedChannelIndex: selectedChannelIndex));
    });

    on<_TVPlayerEventChangeFocus>((event, emit) {
      focusEnum = event.focusEnum;
      emit(TvPlayerState(
          status: TVPlayerStatus.loaded,
          selectedChannelIndex: selectedChannelIndex,
          showChannelList: showChannelList,
          selectedCategoryIndex: selectedCategoryIndex,
          focusEnum: focusEnum,
          channels: channels,
          allChannels: allChannels,
          categories: categories));
    });
  }
}

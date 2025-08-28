import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/input/input_icon_form_field_small.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/input/virtual_keyboard.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/video_card_list_skeleton.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchBloc searchBloc = instance<SearchBloc>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _keyboardFocus = FocusNode();
  final FocusNode _firstCardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchBloc.add(SearchEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          BlurBackground(
            top: 0,
            left: 0,
            width: 300,
            height: 300,
            offset: Offset(-100, 0),
          ),
          BlurBackground(
            right: 0,
            bottom: 0,
            width: 300,
            height: 300,
            offset: Offset(100, 0),
          ),
          Positioned.fill(
            child: BlocConsumer<SearchBloc, SearchState>(
              bloc: searchBloc,
              listener: (context, state) {
                if (state is SearchStateLoaded) {
                  if (state.status == SearchStateStatus.loadedVideos) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _firstCardFocusNode.requestFocus();
                    });
                  }
                }
              },
              builder: (context, state) {
                if (state is SearchStateLoaded) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppPadding.p16.r,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          spacing: AppPadding.p16.r,
                          children: [
                            TextFormFieldIconSmall(
                              borderRadius: AppSize.s200,
                              onChanged: (value) {},
                              controller: _searchController,
                              validatorFunction: (value) {},
                              rightIcon: Icons.search,
                              readOnly: true,
                            ),
                            VirtualKeyboard(
                              focusNode: _keyboardFocus,
                              onKeyPressed: (String key) {
                                _searchController.text += key;
                              },
                              onBackspace: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchController.text = _searchController.text.substring(0, _searchController.text.length - 1);
                                }
                              },
                              onSpace: () {
                                _searchController.text += ' ';
                              },
                              onEnter: () {
                                searchBloc.add(SearchEvent.search(_searchController.text));
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: state.status == SearchStateStatus.loadingVideos
                                  ? VideoCardListSkeleton()
                                  : VideoCardList(
                                      videos: state.videos ?? [],
                                      firstCardFocusNode: _firstCardFocusNode,
                                      columns: 4,
                                    ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }
}

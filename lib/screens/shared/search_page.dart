import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_listener.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
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

  @override
  void initState() {
    super.initState();
    searchBloc.add(SearchEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveManager(
      mobileView: _mobileView(),
      desktopView: _desktopView(),
    );
  }

  AppScaffold _mobileView() {
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
              searchListener(context, state);
            },
            builder: (context, state) {
              if (state is SearchStateLoaded) {
                return Column(
                  children: [
                    SearchInput(
                      searchController: _searchController,
                      keyboardFocus: _keyboardFocus,
                      searchBloc: searchBloc,
                    ),
                    Expanded(child: SearchResults().withPadding(top: AppPadding.p16)),
                  ],
                ).withPadding(top: AppPadding.p16);
              }
              return const SizedBox.shrink();
            },
          ),
        )
      ],
    ));
  }

  AppScaffold _desktopView() {
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
                searchListener(context, state);
              },
              builder: (context, state) {
                if (state is SearchStateLoaded) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppPadding.p16.r,
                    children: [
                      Expanded(
                        flex: 6,
                        child: SearchInput(searchController: _searchController, keyboardFocus: _keyboardFocus, searchBloc: searchBloc),
                      ),
                      Expanded(
                        flex: 10,
                        child: SearchResults(),
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

class SearchResults extends StatefulWidget {
  const SearchResults({
    super.key,
  });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  final searchBloc = instance<SearchBloc>();
  bool isTV = PlatformUtils.isTV;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: searchBloc,
      builder: (context, state) {
        if (state is SearchStateLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              state.search.isNotEmpty ? Text('Titulos con "${state.search}"...', style: Theme.of(context).textTheme.bodyLarge) : const SizedBox.shrink(),
              Expanded(
                child: state.status == SearchStateStatus.loadingVideos
                    ? VideoCardListSkeleton()
                    : VideoCardList(
                        videos: state.videos ?? [],
                        columns: isTV ? 4 : null,
                      ),
              )
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required TextEditingController searchController,
    required FocusNode keyboardFocus,
    required this.searchBloc,
  })  : _searchController = searchController,
        _keyboardFocus = keyboardFocus;

  final TextEditingController _searchController;
  final FocusNode _keyboardFocus;
  final SearchBloc searchBloc;

  @override
  Widget build(BuildContext context) {
    final isTV = PlatformUtils.isTV;
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        spacing: AppPadding.p16.r,
        children: [
          TextFormFieldIconSmall(
            borderRadius: AppSize.s200,
            onChanged: (value) {},
            controller: _searchController,
            validatorFunction: (value) {
              if (value!.isEmpty) {
                return 'Por favor, ingresa un titulo para buscar';
              }
              return null;
            },
            rightIcon: Icons.search,
            readOnly: isTV ? true : false,
            canRequestFocus: isTV ? false : true,
            hint: "Buscar por titulo",
            onEditingComplete: () {
              if (isTV) {
                return;
              }
              searchBloc.add(SearchEvent.search(_searchController.text));
            },
            rightIconOnEditingComplete: isTV ? false : true,
          ),
          if (isTV)
            VirtualKeyboard(
              paddingContainer: 0,
              colorBorder: ColorManager.transparent,
              borderWidth: 0,
              showHeaderIndicator: false,
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
                if (_searchController.text.isNotEmpty) {
                  formKey.currentState?.validate();
                  if (formKey.currentState?.validate() ?? false) {
                    searchBloc.add(SearchEvent.search(_searchController.text));
                  }
                }
              },
              labelLastButton: 'Buscar',
            ),
        ],
      ),
    );
  }
}

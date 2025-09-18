import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/domain/repositories/user_repository.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/auth/auth_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_listener.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/live_tv_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/profile_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/dialog/app_dialog_customize.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc homeBloc = instance<HomeBloc>();
  final SearchBloc searchBloc = instance<SearchBloc>();
  final AuthBloc authBloc = instance<AuthBloc>();
  final livePlayerBloc = instance<TvPlayerBloc>();
  final bool isScrollTV = PlatformUtils.isScrollTV;

  int _currentIndex = 0;
  UserRepository userRepository = instance<UserRepository>();
  bool isLandscape = false;

  @override
  void initState() {
    homeBloc.add(HomeEvent.started());
    searchBloc.add(SearchEvent.getInitialVideos());
    authBloc.add(AuthEvent.validateExpiration());
    livePlayerBloc.add(TvPlayerEvent.started());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoggerManager.log.i(await userRepository.getToken());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          bloc: homeBloc,
          listener: (context, state) {
            homeListener(context, state);
          },
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AppDialogCustomize(
              type: AppDialogCustomizeType.warning,
              message: "¿Desea salir de la app?",
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              labelActionButton: "Aceptar",
              iconActionButton: Icons.check_rounded,
            ),
          );

          return result ?? false;
        },
        child: ResponsiveManager(
          desktopView: _desktopView(),
          mobileView: _mobileView(),
        ),
      ),
    );
  }

  Widget _getBody() {
    if (_currentIndex == 0) return HomeTabBar();
    if (_currentIndex == 1 && isScrollTV) return LiveTvDetail();
    return ProfilePage();
  }

  Widget _mobileView() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorManager.surfaceContainerLowest,
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory, // elimina ripple
            highlightColor: Colors.transparent, // elimina highlight
            splashColor: Colors.transparent,
          ),
          child: isLandscape
              ? SizedBox()
              : BottomNavigationBar(
                  useLegacyColorScheme: false,

                  backgroundColor: ColorManager.surfaceContainerLowest,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },

                  currentIndex: _currentIndex,
                  selectedItemColor: ColorManager.primary, // color del texto activo
                  unselectedItemColor: Colors.white, // color de los inactivos
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    if (isScrollTV)
                      BottomNavigationBarItem(
                        activeIcon: SvgPicture.asset(ImageAssets.iconLive, color: ColorManager.primary),
                        icon: SvgPicture.asset(ImageAssets.iconLive),
                        label: 'Search',
                      ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          bloc: homeBloc,
          builder: (context, state) {
            return _getBody();
          },
        ),
      ),
    );
  }

  Widget _desktopView() {
    return AppScaffold(
      padding: AppPadding.p0,
      body: Column(
        spacing: AppPadding.p16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              bloc: homeBloc,
              builder: (context, state) {
                return HomeTabBar();
              },
            ),
          ),
        ],
      ),
    );
  }
}

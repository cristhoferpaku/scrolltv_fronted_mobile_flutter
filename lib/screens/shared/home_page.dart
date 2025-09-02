import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/templates/live_tv_detail.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/home/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/search/search_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/providers/profile/profile_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/screens/shared/profile_page.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc homeBloc = instance<HomeBloc>();
  final ProfileBloc profileBloc = instance<ProfileBloc>();
  final SearchBloc searchBloc = instance<SearchBloc>();
  final bool isScrollTV = PlatformUtils.isScrollTV;

  int _currentIndex = 0;

  @override
  void initState() {
    homeBloc.add(HomeEvent.started());
    profileBloc.add(ProfileEvent.started());
    searchBloc.add(SearchEvent.getInitialVideos());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveManager(
      desktopView: _desktopView(),
      mobileView: _mobileView(),
    );
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
          child: BottomNavigationBar(
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
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeTabBar(),
            if (isScrollTV) LiveTvDetail(),
            ProfilePage(),
          ],
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
            child: BlocConsumer<HomeBloc, HomeState>(
              bloc: homeBloc,
              listener: (context, state) {},
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

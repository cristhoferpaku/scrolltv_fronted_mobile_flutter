import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/gradient_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/components/molecules/logout_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/components/molecules/policy_and_privace_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/components/molecules/profile_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/providers/profile/profile_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileBloc profileBloc = instance<ProfileBloc>();
  @override
  void initState() {
    profileBloc.add(const ProfileEvent.started());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveManager(
      mobileView: _mobileView(),
      desktopView: _desktopView(),
    );
  }

  Widget _mobileView() {
    return AppScaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (state.status == ProfileStatus.logoutSuccess) {
              Navigator.pushNamed(context, Routes.inicioRoute);
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return Stack(
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
                Column(
                  spacing: AppPadding.p16.r,
                  children: [
                    ProfileCard(
                      user: state.user,
                      onTap: () {},
                    ),
                    Row(
                      spacing: AppPadding.p16.r,
                      children: [
                        Expanded(
                          child: PolicyAndPrivaceCard(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.termsAndConditionsRoute);
                            },
                          ),
                        ),
                        Expanded(child: LogoutCard(
                          onTap: () {
                            profileBloc.add(ProfileEvent.logout());
                          },
                        )),
                      ],
                    ),
                  ],
                ).withPadding(top: AppPadding.p16.r),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _desktopView() {
    return AppScaffold(
      backgroundImage: ImageAssets.backgroundTv,
      linearGradient: GradientManager().background(),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (state.status == ProfileStatus.logoutSuccess) {
              Navigator.pushNamed(context, Routes.inicioRoute);
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return FocusTraversalGroup(
              policy: CustomGridTraversalPolicyStrictVertical(),
              child: Column(
                spacing: AppPadding.p16,
                children: [
                  HomeNavbar(),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch, // estira en alto
                      spacing: AppPadding.p16,
                      children: [
                        Flexible(
                          flex: 2,
                          child: ProfileCard(
                            user: state.user,
                            onTap: () {},
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: PolicyAndPrivaceCard(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.termsAndConditionsRoute);
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: LogoutCard(
                            onTap: () {
                              profileBloc.add(ProfileEvent.logout());
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/gradient_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/providers/profile/profile_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
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
            return Column(
              spacing: AppPadding.p16,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeNavbar(),
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
                ),
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
            return Column(
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
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class BlurContainer extends StatelessWidget {
  const BlurContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: ColorManager.primary),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final UserModel? user;
  final Function() onTap;
  const ProfileCard({
    super.key,
    this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: () {},
      child: BlurContainer(
        child: Row(
          spacing: AppPadding.p16,
          children: [
            CircleAvatar(
              radius: 75.r / 2,
              child: Text("D", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 38.r)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppPadding.p4.r,
                children: [
                  InfoRow(label: "Cuenta: ", value: user?.username ?? ""),
                  InfoRow(label: "Fecha de expiración: ", value: user?.expirationDate ?? ""),
                  InfoRow(label: "Paquete: ", value: user?.packageUserName ?? ""),
                ],
              ),
            ),
          ],
        ).withPadding(all: 12.w),
      ),
    );
  }
}

class PolicyAndPrivaceCard extends StatelessWidget {
  final Function() onTap;
  const PolicyAndPrivaceCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: onTap,
      child: BlurContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageAssets.iconPrivacyAndPolicy,
              height: 32.r,
            ),
            Text("Política & Privacidad", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.r)).withPadding(top: AppPadding.p8.r),
          ],
        ).withPadding(all: 12.w),
      ),
    );
  }
}

class LogoutCard extends StatelessWidget {
  final Function() onTap;
  const LogoutCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      onTap: onTap,
      child: BlurContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageAssets.iconLogout,
              height: 32.r,
            ),
            Text("Cerrar sesión", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.r)).withPadding(top: AppPadding.p8.r),
          ],
        ).withPadding(all: 12.w),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Baseline(
          baseline: 16.r,
          baselineType: TextBaseline.alphabetic,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16.r,
                ),
          ),
        ),
        Baseline(
          baseline: 16.r, // 🔑 mismo valor para alinear ambos abajo
          baselineType: TextBaseline.alphabetic,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.r,
                ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/info_row.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/blur_container.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/profile/ui/providers/profile/profile_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/user/domain/entities/user_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/text_skeleton.dart';

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
    final profileBloc = instance<ProfileBloc>();
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return ContainerFocus(
            onTap: () {},
            child: BlurContainer(
              child: Row(
                spacing: AppPadding.p16,
                children: [
                  CircleAvatar(
                    radius: 75.r / 2,
                    child: Text(state.firstLetterUsername ?? "", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 38.r)),
                  ),
                  if (state.status == ProfileStatus.loading)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppPadding.p8.r,
                        children: [
                          TextSkeleton(),
                          TextSkeleton(),
                          TextSkeleton(),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppPadding.p4.r,
                        children: [
                          InfoRow(label: "Cuenta: ", value: state.user?.username ?? ""),
                          InfoRow(label: "Fecha de expiración: ", value: state.user?.expirationDate ?? ""),
                          InfoRow(label: "Paquete: ", value: state.user?.packageUserName ?? ""),
                        ],
                      ),
                    ),
                ],
              ).withPadding(all: 12.w),
            ),
          );
        }
        return Container();
      },
    );
  }
}

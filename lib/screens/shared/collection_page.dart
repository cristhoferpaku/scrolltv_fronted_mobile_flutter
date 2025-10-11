import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_arguments.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/components/molecules/blur_background.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/video_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/collection/collection_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/skeleton/collection_skeleton.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final collectionBloc = instance<CollectionBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as CollectionPageArguments;
      collectionBloc.add(CollectionEvent.started(arguments.collectionId, arguments.collectionName));
    });
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
          SingleChildScrollView(
            child: BlocConsumer<CollectionBloc, CollectionState>(
              bloc: collectionBloc,
              listener: (context, state) {},
              builder: (context, state) {
                if (state is CollectionStateLoaded) {
                  if (state.status == CollectionStateStatus.loading) {
                    return CollectionSkeleton();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerFocus(
                        autofocus: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, color: ColorManager.white).withPadding(all: AppPadding.p8),
                      ).withPadding(top: AppPadding.p16),
                      Text(
                        state.collectionName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ).withPadding(top: AppPadding.p16),
                      if (state.videos != null)
                        SizedBox(
                          height: .9.sh,
                          child: VideoCardList(videos: state.videos!),
                        ).withPadding(top: AppPadding.p16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

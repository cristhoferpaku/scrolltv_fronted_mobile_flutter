import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/linear_gradient_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/scroll_to_top_on_up.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_hero.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar_normal.dart';

class VideoDetailsPage extends StatefulWidget {
  const VideoDetailsPage({super.key});

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: 0,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FocusTraversalGroup(
          policy: CustomGridTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HomeHero(
                height: .9.sh,
                detailsDisabled: true,
                goBack: true,
                video: VideoModel(
                  id: 1,
                  title: "Video 1",
                  description:
                      "Miles regresa para un nuevo capítulo de esta galardonada saga donde deberá reevaluar el significado de ser héroe cuando es obligado a enfrentar a todo un equipo de héroes arácnidos encargados de proteger la existencia misma del Multiverso.",
                  coverImage:
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSocErq1QEBqh8nni6H9Kfxa9teMfXSpg0jzQ&s",
                  bannerImage:
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSocErq1QEBqh8nni6H9Kfxa9teMfXSpg0jzQ&s",
                  year: "2022",
                  duration: "1h 30m",
                  categories: "Action",
                  collectionName: "Collection 1",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: AppPadding.p32.r,
                children: [
                  SizedBox(
                    height: 240.r,
                    child: CustomTabBarNormal(
                      items: [
                        CustomTabBarItem(
                          title: "Temporada 1",
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: AppPadding.p16.r,
                              children: [
                                ...List.generate(
                                  4,
                                  (index) => EpisodeCard(),
                                ),
                              ],
                            ).withPadding(top: AppPadding.p16.r),
                          ),
                        ),
                        CustomTabBarItem(
                          title: "Temporada 2",
                          child: Text("Información 2"),
                        ),
                      ],
                      titleBar: Text(""),
                    ),
                  ),
                  CastCardList(),
                  SectionCardList(title: "Recien llegados", videos: []),
                  SectionCardList(title: "Más vistas", videos: []),
                  SectionCardList(title: "Netflix", videos: []),
                ],
              ).withPadding(
                  top: AppPadding.p32.r, horizontal: AppPadding.p16.r),
            ],
          ),
        ),
      ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerFocus(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppSize.s16.r,
              ),
              border: Border.all(
                color: ColorManager.white.withValues(alpha: 0.2),
                width: AppSize.s2.r,
              ),
              image: DecorationImage(
                image: NetworkImage(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSocErq1QEBqh8nni6H9Kfxa9teMfXSpg0jzQ&s",
                ),
                fit: BoxFit.cover,
              ),
            ),
            width: 300.r,
            height: 190.r,
          ),
          Positioned.fill(
            child: LinearGradientBox(
              colors: [
                Colors.black.withValues(alpha: 1),
                Colors.black.withValues(alpha: 0),
              ],
              stops: [0.0, 1.0],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          Positioned(
            left: 8.r,
            bottom: 8.r,
            child: Text("Ep 1"),
          ),
        ],
      ),
    );
  }
}

class CastCardList extends StatelessWidget {
  const CastCardList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: AppPadding.p12.r,
      children: [
        Text("Reparto", style: Theme.of(context).textTheme.titleLarge),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppPadding.p24.r,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              15,
              (index) => CastCard(),
            ),
          ),
        ),
      ],
    );
  }
}

class CastCard extends StatelessWidget {
  const CastCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppPadding.p10.r,
      children: [
        CircleAvatar(
          radius: 44.r / 2,
          child: Text("D"),
        ),
        Text("Director"),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/bloc/custom_tab_bar_bloc.dart';

class CustomTabBarItem {
  String title;
  IconData? icon;
  Widget child;

  CustomTabBarItem({required this.title, this.icon, required this.child});
}

class CustomTabBar extends StatefulWidget {
  final List<CustomTabBarItem> items;
  final Widget titleBar;
  const CustomTabBar({super.key, required this.items, required this.titleBar});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final bloc = instance<CustomTabBarBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(const CustomTabBarEvent.started());

    tabController = TabController(length: widget.items.length, vsync: this);
    tabController.addListener(() {
      bloc.add(CustomTabBarEvent.changeTab(tabController.index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTabBarBloc, CustomTabBarState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is CustomTabBarStateLoaded) {
          return LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: TabBarView(
                      controller: tabController,
                      children: widget.items.map((item) => item.child).toList(),
                    ),
                  ),
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.titleBar.withPadding(),
                        Container(
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: ColorManager.transparent,
                            borderRadius: BorderRadius.circular(AppSize.s10),
                          ),
                          padding: EdgeInsets.zero,
                          child: TabBar(
                            splashFactory: NoSplash.splashFactory,
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            indicatorColor: ColorManager.transparent,
                            controller: tabController,
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            unselectedLabelStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            tabs: [
                              ...widget.items.asMap().entries.map((entry) {
                                int position = entry.key;
                                CustomTabBarItem value = entry.value;
                                bool isCurrentIndex =
                                    position == state.currentIndex;
                                return Tab(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isCurrentIndex
                                          ? ColorManager.primaryContainer
                                          : ColorManager.transparent,
                                      borderRadius:
                                          BorderRadius.circular(AppSize.s10),
                                    ),
                                    alignment: Alignment.center,
                                    height: AppSize.s36,
                                    child: Row(
                                      spacing: AppPadding.p8,
                                      children: [
                                        if (value.icon != null)
                                          Icon(value.icon!,
                                              size: AppSize.s24,
                                              color: ColorManager
                                                  .onPrimaryContainer),
                                        Text(value.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                    color: ColorManager
                                                        .onPrimaryContainer)),
                                      ],
                                    ).withPadding(horizontal: AppPadding.p16),
                                  ).withPadding(
                                      left: position != 0
                                          ? AppPadding.p16
                                          : AppPadding.p16),
                                );
                              })
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Container(
                        //     child: TabBarView(
                        //       controller: tabController,
                        //       children: widget.items
                        //           .map((item) => item.child)
                        //           .toList(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Positioned(
                  //   top: 0,
                  //   left: 0,
                  //   child: Container(
                  //     child: TabBarView(
                  //       controller: tabController,
                  //       children:
                  //           widget.items.map((item) => item.child).toList(),
                  //     ).withPadding(top: AppPadding.p12),
                  //   ),
                  // ),
                ],
              ),
            );
          });
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
// import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
// import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
// import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
// import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/bloc/custom_tab_bar_bloc.dart';

// class CustomTabBarItem {
//   String title;
//   IconData? icon;
//   Widget child;

//   CustomTabBarItem({required this.title, this.icon, required this.child});
// }

// class CustomTabBar extends StatefulWidget {
//   final List<CustomTabBarItem> items;
//   final Widget titleBar;
//   const CustomTabBar({super.key, required this.items, required this.titleBar});

//   @override
//   State<CustomTabBar> createState() => _CustomTabBarState();
// }

// class _CustomTabBarState extends State<CustomTabBar>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   final bloc = instance<CustomTabBarBloc>();

//   @override
//   void initState() {
//     super.initState();
//     bloc.add(const CustomTabBarEvent.started());

//     tabController = TabController(length: widget.items.length, vsync: this);
//     tabController.addListener(() {
//       bloc.add(CustomTabBarEvent.changeTab(tabController.index));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CustomTabBarBloc, CustomTabBarState>(
//       bloc: bloc,
//       builder: (context, state) {
//         if (state is CustomTabBarStateLoaded) {
//           return LayoutBuilder(builder: (context, constraints) {
//             return SizedBox(
//               height: constraints.maxHeight,
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Positioned.fill(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         widget.titleBar.withPadding(),
//                         Container(
//                           width: constraints.maxWidth,
//                           decoration: BoxDecoration(
//                             color: ColorManager.transparent,
//                             borderRadius: BorderRadius.circular(AppSize.s10),
//                           ),
//                           padding: EdgeInsets.zero,
//                           child: TabBar(
//                             splashFactory: NoSplash.splashFactory,
//                             tabAlignment: TabAlignment.start,
//                             isScrollable: true,
//                             indicatorColor: ColorManager.transparent,
//                             controller: tabController,
//                             labelPadding: EdgeInsets.zero,
//                             padding: EdgeInsets.zero,
//                             labelStyle: Theme.of(context).textTheme.bodyMedium,
//                             unselectedLabelStyle:
//                                 Theme.of(context).textTheme.bodyMedium,
//                             tabs: [
//                               ...widget.items.asMap().entries.map((entry) {
//                                 int position = entry.key;
//                                 CustomTabBarItem value = entry.value;
//                                 bool isCurrentIndex =
//                                     position == state.currentIndex;
//                                 return Tab(
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: isCurrentIndex
//                                           ? ColorManager.primaryContainer
//                                           : ColorManager.transparent,
//                                       borderRadius:
//                                           BorderRadius.circular(AppSize.s10),
//                                     ),
//                                     alignment: Alignment.center,
//                                     height: AppSize.s36,
//                                     child: Row(
//                                       spacing: AppPadding.p8,
//                                       children: [
//                                         if (value.icon != null)
//                                           Icon(value.icon!,
//                                               size: AppSize.s24,
//                                               color: ColorManager
//                                                   .onPrimaryContainer),
//                                         Text(value.title,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .labelMedium
//                                                 ?.copyWith(
//                                                     color: ColorManager
//                                                         .onPrimaryContainer)),
//                                       ],
//                                     ).withPadding(horizontal: AppPadding.p16),
//                                   ).withPadding(
//                                       left: position != 0
//                                           ? AppPadding.p16
//                                           : AppPadding.p16),
//                                 );
//                               })
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             child: TabBarView(
//                               controller: tabController,
//                               children: widget.items
//                                   .map((item) => item.child)
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Positioned(
//                   //   top: 0,
//                   //   left: 0,
//                   //   child: Container(
//                   //     child: TabBarView(
//                   //       controller: tabController,
//                   //       children:
//                   //           widget.items.map((item) => item.child).toList(),
//                   //     ).withPadding(top: AppPadding.p12),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             );
//           });
//         } else {
//           return const SizedBox.shrink();
//         }
//       },
//     );
//   }
// }

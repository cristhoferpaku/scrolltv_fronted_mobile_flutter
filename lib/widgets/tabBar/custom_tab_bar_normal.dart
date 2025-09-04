import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/bloc/custom_tab_bar_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/tabBar/custom_tab_bar.dart';

class CustomTabBarNormal extends StatefulWidget {
  final List<CustomTabBarItem> items;
  final Widget titleBar;
  final bool fixed;
  const CustomTabBarNormal({super.key, required this.items, required this.titleBar, this.fixed = false});

  @override
  State<CustomTabBarNormal> createState() => _CustomTabBarNormalState();
}

class _CustomTabBarNormalState extends State<CustomTabBarNormal> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final bloc = instance<CustomTabBarBloc>();

  bool _showHeader = true; // Para controlar visibilidad
  final isTv = PlatformUtils.isTV;

  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    bloc.add(const CustomTabBarEvent.started());

    tabController = TabController(length: widget.items.length, vsync: this);
    tabController.addListener(() {
      _focusNodes[tabController.index].requestFocus();

      bloc.add(CustomTabBarEvent.changeTab(tabController.index));
    });

    _focusNodes = List.generate(widget.items.length, (_) => FocusNode());
  }

  int lastItemWithFocus = 0;

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
                  if (_showHeader) // Solo mostramos si está arriba
                    Positioned.fill(
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
                            child: Center(
                              child: TabBar(
                                splashFactory: NoSplash.splashFactory,
                                tabAlignment: isTv ? TabAlignment.center : TabAlignment.start,
                                isScrollable: true,
                                indicatorColor: ColorManager.white,
                                controller: tabController,
                                labelPadding: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                labelStyle: Theme.of(context).textTheme.bodyMedium,
                                unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                                tabs: [
                                  ...widget.items.asMap().entries.map((entry) {
                                    int position = entry.key;
                                    CustomTabBarItem value = entry.value;
                                    bool isCurrentIndex = position == state.currentIndex;
                                    return FocusableActionDetector(
                                      focusNode: _focusNodes[position],
                                      onFocusChange: (hasFocus) {
                                        setState(() {});
                                        if (lastItemWithFocus != 0) {
                                          _focusNodes[lastItemWithFocus].requestFocus();
                                          lastItemWithFocus = 0;
                                          return;
                                        }
                                        final focusedNode = FocusManager.instance.primaryFocus;
                                        if (_focusNodes.contains(focusedNode)) {
                                          tabController.animateTo(position);
                                        } else {
                                          lastItemWithFocus = position;
                                        }
                                      },
                                      child: Tab(
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: AppSize.s36,
                                          child: Row(
                                            spacing: AppPadding.p8,
                                            children: [
                                              if (value.icon != null) value.icon!,
                                              Text(value.title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: ColorManager.onPrimaryContainer)),
                                            ],
                                          ).withPadding(horizontal: AppPadding.p16),
                                        ).withPadding(left: position != 0 ? AppPadding.p16 : AppPadding.p16),
                                      ),
                                    );
                                  })
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: tabController,
                              children: widget.items.map((item) {
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    // Solo nos interesa si hubo scroll vertical
                                    final isVertical = scrollInfo.metrics.axis == Axis.vertical;

                                    if (isVertical) {
                                      final atTop = scrollInfo.metrics.pixels <= 0;
                                      if (atTop != _showHeader) {
                                        setState(() {
                                          _showHeader = atTop;
                                        });
                                      }
                                    }

                                    return false;
                                  },
                                  child: item.child,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
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

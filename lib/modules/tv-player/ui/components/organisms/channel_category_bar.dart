import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_category_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class ChannelCategoryBar extends StatefulWidget {
  final List<ChannelCategoryModel> categories;
  final int selectedCategoryIndex;

  const ChannelCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
  });

  @override
  State<ChannelCategoryBar> createState() => _ChannelCategoryBarState();
}

class _ChannelCategoryBarState extends State<ChannelCategoryBar> {
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();
  final ItemScrollController _scrollController = ItemScrollController();

  void _scrollTo(int index) {
    if (_scrollController.isAttached) {
      _scrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        alignment: 0.15, // 👈 inicio en vez de centro
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: SizedBox(
            height: 40,
            child: ScrollablePositionedList.separated(
              scrollDirection: Axis.horizontal,
              itemScrollController: _scrollController,
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isSelected = widget.selectedCategoryIndex == index;

                return ElevatedButtonApp(
                  textButton: category.name,
                  paddingHorizontal: 24,
                  paddingVertical: 6,
                  press: () {
                    tvPlayerBloc.add(TvPlayerEvent.changeCategory(index));
                    _scrollTo(index);
                  },
                  colorButton: isSelected ? ColorManager.primaryContainer : Colors.transparent,
                  textStyleButton: Theme.of(context).textTheme.labelMedium,
                  isExpanded: false,
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.black87,
              builder: (context) {
                return SafeArea(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: ColorManager.onInverseSurface,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3.8,
                      ),
                      itemCount: widget.categories.length,
                      itemBuilder: (context, index) {
                        final category = widget.categories[index];
                        final isSelected = widget.selectedCategoryIndex == index;
                        return ElevatedButtonApp(
                          evelationButton: 0,
                          hasShadow: false,
                          textButton: category.name,
                          paddingHorizontal: 24,
                          paddingVertical: 6,
                          press: () {
                            tvPlayerBloc.add(TvPlayerEvent.changeCategory(index));
                            Navigator.pop(context); // 👈 cerrar modal
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollTo(index); // 👈 desplazar
                            });
                          },
                          colorButton: isSelected ? ColorManager.primaryContainer : ColorManager.onInverseSurface,
                          textStyleButton: Theme.of(context).textTheme.labelMedium,
                          isExpanded: false,
                        );
                      },
                    ).withPadding(all: 16),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

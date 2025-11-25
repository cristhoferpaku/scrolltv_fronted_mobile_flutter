import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/no_content_box.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';

class CollectionList extends StatelessWidget {
  final List<CollectionModel> collection;
  const CollectionList({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    if (collection.isEmpty) {
      return NoContentBox();
    }
    return Column(
      children: [
        ...collection.asMap().entries.map((entry) {
          // final index = entry.key;
          final e = entry.value;
          final index = entry.key;

          return SectionCardList(
            title: e.collectionName ?? "",
            videos: e.content ?? [],
            id: e.collectionId ?? 0,
            hasBlurLeft: index % 2 == 0,
            hasBlurRight: index % 2 == 0,
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/section_card_list.dart';

class CollectionList extends StatelessWidget {
  final List<CollectionModel> collection;
  const CollectionList({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...collection.asMap().entries.map((entry) {
          // final index = entry.key;
          final e = entry.value;
          return SectionCardList(
            title: e.collectionName ?? "",
            videos: e.content ?? [],
            id: e.collectionId ?? 0,
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/components/organisms/color_card_list.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/constants/data/colors_data.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: AppPadding.p16,
            children: [
              Text('Colores', style: Theme.of(context).textTheme.titleLarge),
              Divider(),
              ColorCardList(colors: colorsData),
            ],
          ),
        ),
      ),
    );
  }
}

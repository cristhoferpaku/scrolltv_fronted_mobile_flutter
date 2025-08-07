import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/constants/data/components_data.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  @override
  Widget build(BuildContext context) {
    final List<Component> componentsList = componentsData;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("Componentes", style: Theme.of(context).textTheme.titleLarge),
            ListView.separated(
              shrinkWrap: true,
              itemCount: componentsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(componentsList[index].name),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      componentsList[index].route,
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: AppSize.s16);
              },
            ),
          ],
        ),
      ),
    );
  }
}

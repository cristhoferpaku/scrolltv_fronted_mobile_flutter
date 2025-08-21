import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_tab_bar.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/providers/bloc/home_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc homeBloc = instance<HomeBloc>();

  @override
  void initState() {
    homeBloc.add(HomeEvent.started());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: AppPadding.p0,
      body: Column(
        spacing: AppPadding.p16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>(
              bloc: homeBloc,
              listener: (context, state) {},
              builder: (context, state) {
                return HomeTabBar();
              },
            ),
          ),
        ],
      ),
    );
  }
}

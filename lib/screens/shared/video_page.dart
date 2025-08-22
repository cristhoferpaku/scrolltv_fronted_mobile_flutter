import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final bool isTV = PlatformUtils.isTV;
  String deviceId = "";
  @override
  void initState() {
    super.initState();
    if (!isTV) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    getDeviceId().then((value) {
      setState(() {
        deviceId = value;
      });
    });
  }

  @override
  void dispose() {
    if (!isTV) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          children: [
            Text("Video Page"),
            Text("Device ID: $deviceId"),
          ],
        ),
      ),
    );
  }
}

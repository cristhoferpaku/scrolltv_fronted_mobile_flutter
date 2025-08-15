import 'package:flutter/material.dart';

class LiveTab extends StatefulWidget {
  const LiveTab({super.key});

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Live"),
    );
  }
}

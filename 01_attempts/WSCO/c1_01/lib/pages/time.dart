import 'package:flutter/material.dart';

class Time extends StatefulWidget {
  final Map<String, dynamic> me;

  const Time({super.key, required this.me});
  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(children: []),
      ),
    );
  }
}

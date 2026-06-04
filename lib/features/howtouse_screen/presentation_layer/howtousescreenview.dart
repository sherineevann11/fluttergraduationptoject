import 'package:flutter/material.dart';
import 'package:graduationproject/features/howtouse_screen/presentation_layer/widgets/howtousescreenbody.dart';

class Howtousescreenview extends StatelessWidget {
  const Howtousescreenview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: HowToUsescreenbody(),
    );
  }
}
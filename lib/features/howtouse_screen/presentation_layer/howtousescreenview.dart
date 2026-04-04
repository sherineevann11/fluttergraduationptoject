import 'package:flutter/material.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/features/howtouse_screen/presentation_layer/widgets/howtousescreenbody.dart';

class Howtousescreenview extends StatelessWidget {
  const Howtousescreenview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كيف يعمل'),
        backgroundColor:AppColors.thirdColor,
      ),
      body: HowToUseScreenBody(),
    );
  }
}
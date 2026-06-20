import 'package:flutter/material.dart';
import 'package:graduationproject/features/history_screen/presentation_layer/widgets/historyscreenbody.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:const HistoryBody(),
      ),
    );
  }
}
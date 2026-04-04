import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/widgets/custom_back_button.dart';

class Dictionaryscreenbody extends StatelessWidget {
  const Dictionaryscreenbody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomBackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 0.h),
                Text(
                  'المعجم الإرشادي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF248DBC),
                    fontSize: 28.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h), // ← تصحيح sizebox → SizedBox

          SizedBox(
            height: 1150.h,
            width: double.infinity,
            child: Image.asset(
              AppAssets.Dicscreen,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }
}
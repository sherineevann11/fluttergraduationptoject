import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/core/widgets/spacing_widgets.dart';
import 'package:graduationproject/core/widgets/login_button.dart';
import 'package:graduationproject/core/widgets/primary_outlined_button.dart';
import 'package:graduationproject/features/lognIn_screen/presentation_layer/loginScreenView.dart';
import 'package:graduationproject/features/signup_screen/presentation_layer/signupscreemView.dart';

class SplashScreenBody extends StatelessWidget {
  const SplashScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background image  ← الفيكس هنا: SizedBox بدل Column
Positioned(
  top: 104.h,
  left: 8,
  right: 12,
  child: Image.asset(
    AppAssets.LoginImage,
    width: double.infinity,
    height: 335.h,
    fit: BoxFit.cover,
  ),
),

          /// Tagline Text
          Positioned(
            top: 446.h,
            left: 58.w,
            right: 65.w,
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '«',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: 'تعلم لغة الإشارة العربية بسهولة',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: ' » ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Buttons
          Positioned(
            top: 585.h,
            left: 43.w,
            child: Column(
              children: [
                /// Log in Button
                LoginButton(
                  buttonText: 'تسجيل الدخول',
                  width: 304.w,
                  height: 76.h,
                  buttonColor: AppColors.primaryColor,
                  textColor: AppColors.thirdColor,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreenView(),
                      ),
                    );
                  },
                ),

                HeightSpace(15.h),

                /// Sign Up Button
                PrimaryOutlinedButton(
                  buttonText: 'إنشاء حساب',
                  width: 304.w,
                  height: 76.h,
                  textColor: AppColors.thirdColor,
                  buttonColor: AppColors.primaryColor,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpScreenView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
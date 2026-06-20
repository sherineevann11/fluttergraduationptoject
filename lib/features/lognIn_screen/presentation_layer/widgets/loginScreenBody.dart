import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/widgets/TextField_button.dart';
import 'package:graduationproject/core/widgets/primary_button.dart';
import 'package:graduationproject/features/auth/controller/auth_controller.dart';
import 'package:graduationproject/features/auth/view/reset_email_screen.dart';
import 'package:graduationproject/features/signup_screen/presentation_layer/signupscreemView.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final AuthController controller = Get.put(AuthController());

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// الصورة العلوية
        Positioned(
          top: -40.h,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 240.h,
            width: double.infinity,
            child: Image.asset(
              AppAssets.Signin_image,
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// حاوية النموذج
        Positioned(
          top: 200.h,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.r),
                topRight: Radius.circular(35.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'اسم المستخدم',
                          hintText: 'أدخل اسم المستخدم',
                          controller: userNameController,
                          keyboardType: TextInputType.text,
                        ),

                        SizedBox(height: 20.h),

                        CustomTextField(
                          label: 'كلمة المرور',
                          hintText: 'أدخل كلمة المرور',
                          controller: passwordController,
                          isPassword: true,
                        ),

                        SizedBox(height: 6.h),

                        /// نسيت كلمة المرور
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResetEmailScreen(),
                              ),
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15.h),

                        /// زر تسجيل الدخول
                        Obx(() => PrimaryButton(
                              buttonText: controller.isLoading.value
                                  ? 'جارٍ التحميل...'
                                  : 'تسجيل الدخول',
                              icon: SvgPicture.asset(
                                AppAssets.iconarrow,
                                width: 20.w,
                                height: 20.h,
                              ),
                              onPress: controller.isLoading.value
                                  ? () {}
                                  : () => controller.login(
                                        userNameController.text.trim(),
                                        passwordController.text.trim(),
                                      ),
                            )),
                      ],
                    ),
                  ),
                ),

                /// إنشاء حساب - ثابتة في الأسفل
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreenView(),
                          ),
                        ),
                        child: Text(
                          'أنشئ حساباً جديداً',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
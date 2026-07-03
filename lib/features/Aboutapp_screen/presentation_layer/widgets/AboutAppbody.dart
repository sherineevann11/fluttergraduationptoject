import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/core/widgets/custom_back_button.dart';
import 'package:graduationproject/features/search_screen/presentation_layer/searchscreenview.dart';

class AboutScreenBody extends StatelessWidget {
  const AboutScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Back Button فقط ───
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomBackButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Searchscreenview(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ─── Tagline ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '"إيماءة.. لغة مشتركة للمجتمع"',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: const Color(0xFF1A8FBF),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Noto Sans Gujarati',
                ),
              ),
            ),
          ),

          SizedBox(height: 22.h),

          // ─── About ───
          _sectionTitle('عن المشروع'),
          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'إيماءة هو أكثر من مجرد تطبيق — إنه منصة ذكية تعتمد على الذكاء الاصطناعي لكسر حاجز التواصل بين الصم وغير الصم في المجتمع العربي، من خلال ترجمة لغة الإشارة في الوقت الفعلي.',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontFamily: 'Noto Sans Gujarati',
                  height: 1.8,
                ),
              ),
            ),
          ),

          SizedBox(height: 22.h),

          // ─── Stats ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                _statCard('+٣٢', 'حرف إشارة', Icons.sign_language_rounded),
                SizedBox(width: 10.w),
                _statCard('٤.٥م', 'أصم في مصر', Icons.people_rounded),
                SizedBox(width: 10.w),
                _statCard('YOLO', 'نموذج AI', Icons.psychology_rounded),
              ],
            ),
          ),

          SizedBox(height: 22.h),

          // ─── Features ───
          _sectionTitle('مميزات التطبيق'),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _featureCard(
                  icon: Icons.mic_rounded,
                  title: 'صوت إلى إشارة',
                  desc: 'سجّل صوتك وشوف ترجمته لصور لغة الإشارة فوراً',
                  color: const Color(0xFF30BBF9),
                ),
                SizedBox(height: 10.h),
                _featureCard(
                  icon: Icons.spellcheck_rounded,
                  title: 'نص إلى إشارة',
                  desc: 'اكتب أي جملة عربية وهيترجملك حرف بحرف',
                  color: const Color(0xFF276C8A),
                ),
                SizedBox(height: 10.h),
                _featureCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'إشارة إلى نص',
                  desc: 'وجّه الكاميرا لإيدك والـ AI يترجم الحركات لكلمات',
                  color: const Color(0xFF5DBBFF),
                ),
                SizedBox(height: 10.h),
                _featureCard(
                  icon: Icons.menu_book_rounded,
                  title: 'معجم لغة الإشارة',
                  desc: 'قاموس شامل لكل حروف الأبجدية العربية',
                  color: const Color(0xFF1A8FBF),
                ),
              ],
            ),
          ),

          SizedBox(height: 22.h),

          // ─── Tech Stack ───
          _sectionTitle('التقنيات المستخدمة'),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _techChip('Flutter', Icons.phone_android_rounded),
                _techChip('.NET Backend', Icons.dns_rounded),
                _techChip('YOLO AI', Icons.auto_awesome_rounded),
                _techChip('SignalR', Icons.bolt_rounded),
                _techChip('Python', Icons.code_rounded),
                _techChip('REST API', Icons.api_rounded),
              ],
            ),
          ),

          SizedBox(height: 22.h),

          // ─── Graduation Card ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_rounded,
                          color: const Color(0xFF1A8FBF), size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'مشروع تخرج',
                        style: TextStyle(
                          color: const Color(0xFF1A8FBF),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Noto Sans Gujarati',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Divider(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      thickness: 1),
                  SizedBox(height: 10.h),
                  Text(
                    'تم تطوير هذا التطبيق كمشروع تخرج بهدف خدمة مجتمع الصم في العالم العربي وتعزيز التواصل والشمول الاجتماعي.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13.sp,
                      fontFamily: 'Noto Sans Gujarati',
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '🎓  كلية الهندسة  •  قسم كهرباء  •  شعبة حاسبات وتحكم',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1A8FBF),
                        fontSize: 12.sp,
                        fontFamily: 'Noto Sans Gujarati',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helpers ───

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 4.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans Gujarati',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: const Color(0xFF1A156C).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20.sp),
            SizedBox(height: 5.h),
            Text(
              number,
              style: TextStyle(
                color: const Color(0xFF1A8FBF),
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 10.sp,
                fontFamily: 'Noto Sans Gujarati',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Noto Sans Gujarati',
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  desc,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.sp,
                    fontFamily: 'Noto Sans Gujarati',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 13.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
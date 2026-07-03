import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduationproject/core/style/app_colors.dart';

class HowToUsescreenbody extends StatefulWidget {
  const HowToUsescreenbody({super.key});

  @override
  State<HowToUsescreenbody> createState() => _HowToUsescreenbodyState();
}

class _HowToUsescreenbodyState extends State<HowToUsescreenbody> {
  int _selectedFeature = 0;

  final List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.mic_rounded,
      title: 'صوت إلى إشارة',
      color: Color(0xFF1A156C),
      steps: [
        _StepData(icon: Icons.touch_app_rounded, text: 'اضغط على زرار الميكروفون'),
        _StepData(icon: Icons.mic_rounded, text: 'ابدأ تتكلم بالعربي بوضوح'),
        _StepData(icon: Icons.stop_circle_rounded, text: 'اضغط تاني عشان توقف التسجيل'),
        _StepData(icon: Icons.sign_language_rounded, text: 'شوف صور الإشارة اللي طلعت لكل كلمة'),
      ],
      tip: 'اتكلم بوضوح وببطء عشان الترجمة تبقى أدق',
    ),
    _FeatureData(
      icon: Icons.spellcheck_rounded,
      title: 'نص إلى إشارة',
      color: Color(0xFF276C8A),
      steps: [
        _StepData(icon: Icons.edit_rounded, text: 'اكتب الجملة اللي عايز تترجمها'),
        _StepData(icon: Icons.translate_rounded, text: 'اضغط على زرار "تحويل النص"'),
        _StepData(icon: Icons.sign_language_rounded, text: 'شوف صور الإشارة لكل كلمة'),
        _StepData(icon: Icons.swipe_rounded, text: 'مرر يمين وشمال عشان تشوف كل الحروف'),
      ],
      tip: 'تقدر تكتب جملة كاملة وهيترجملك كلمة كلمة',
    ),
    _FeatureData(
      icon: Icons.camera_alt_rounded,
      title: 'إشارة إلى نص',
      color: Color(0xFF1A156C),
      steps: [
        _StepData(icon: Icons.wifi_rounded, text: 'تأكد إن عندك إنترنت كويس'),
        _StepData(icon: Icons.videocam_rounded, text: 'اضغط "شغل الكاميرا"'),
        _StepData(icon: Icons.back_hand_rounded, text: 'وجّه إيدك للكاميرا واعمل الإشارة'),
        _StepData(icon: Icons.text_fields_rounded, text: 'شوف الحروف بتتكوّن تلقائياً'),
        _StepData(icon: Icons.library_add_check_rounded, text: 'اضغط "كلمة جديدة" لما تخلص الكلمة'),
        _StepData(icon: Icons.auto_fix_high_rounded, text: 'اضغط "صحح الجملة" للحصول على نص سليم'),
      ],
      tip: 'اضمن الإضاءة كويسة وإيدك واضحة في الكاميرا',
    ),
    _FeatureData(
      icon: Icons.menu_book_rounded,
      title: 'المعجم',
      color: Color(0xFF1A156C),
      steps: [
        _StepData(icon: Icons.search_rounded, text: 'دور على الحرف أو الكلمة اللي عايزها'),
        _StepData(icon: Icons.touch_app_rounded, text: 'اضغط عليها عشان تشوف صورة الإشارة'),
        _StepData(icon: Icons.zoom_in_rounded, text: 'تقدر تكبّر الصورة للتفاصيل'),
      ],
      tip: 'المعجم فيه كل حروف الأبجدية العربية بلغة الإشارة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final feature = _features[_selectedFeature];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: Column(
        children: [
          // ─── Header ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryColor, const Color(0xFF276C8A)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  children: [
                    // Back + Title
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'كيف تستخدم إيماءة؟',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Noto Sans Gujarati',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Feature Selector Tabs
                    SizedBox(
                      height: 72.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        itemCount: _features.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, i) {
                          final f = _features[i];
                          final isSelected = i == _selectedFeature;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFeature = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    f.icon,
                                    color: isSelected ? f.color : Colors.white,
                                    size: 22.sp,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    f.title,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: isSelected
                                          ? f.color
                                          : Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Noto Sans Gujarati',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Content ───
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: SingleChildScrollView(
                key: ValueKey(_selectedFeature),
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Feature Title
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: feature.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(feature.icon,
                              color: feature.color, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          feature.title,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: feature.color,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Noto Sans Gujarati',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Steps
                    ...feature.steps.asMap().entries.map((e) {
                      final idx = e.key;
                      final step = e.value;
                      return _buildStep(
                        number: idx + 1,
                        icon: step.icon,
                        text: step.text,
                        color: feature.color,
                        isLast: idx == feature.steps.length - 1,
                      );
                    }),

                    SizedBox(height: 20.h),

                    // Tip Box
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: feature.color.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: feature.color.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_rounded,
                              color: feature.color, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              feature.tip,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13.sp,
                                fontFamily: 'Noto Sans Gujarati',
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Navigation Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _features.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: i == _selectedFeature ? 20.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: i == _selectedFeature
                                ? feature.color
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Next / Prev Buttons
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        if (_selectedFeature < _features.length - 1)
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFeature++),
                              child: Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: feature.color,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text(
                                      'التالي',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Noto Sans Gujarati',
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(Icons.arrow_back_ios_rounded,
                                        color: Colors.white, size: 16.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_selectedFeature > 0) ...[
                          SizedBox(width: 10.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFeature--),
                              child: Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey.shade600,
                                        size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'السابق',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Noto Sans Gujarati',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required IconData icon,
    required String text,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number + Line
        Column(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 36.h,
                color: color.withOpacity(0.25),
              ),
          ],
        ),

        SizedBox(width: 14.w),

        // Card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    text,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.sp,
                      fontFamily: 'Noto Sans Gujarati',
                      height: 1.4,
                    ),
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

// ─────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────

class _FeatureData {
  final IconData icon;
  final String title;
  final Color color;
  final List<_StepData> steps;
  final String tip;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.color,
    required this.steps,
    required this.tip,
  });
}

class _StepData {
  final IconData icon;
  final String text;

  const _StepData({required this.icon, required this.text});
}

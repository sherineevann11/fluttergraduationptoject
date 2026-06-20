import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:intl/intl.dart';
import 'package:graduationproject/features/auth/controller/history_controller.dart';

class HistoryBody extends StatefulWidget {
  const HistoryBody({super.key});
  @override
  State<HistoryBody> createState() => _HistoryBodyState();
}
 
class _HistoryBodyState extends State<HistoryBody> {
  @override
  Widget build(BuildContext context) {
    final HistoryController historyController = Get.put(HistoryController());
 
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(
          () => historyController.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF30BBF9)))
              : Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // عنوان السجل
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'السجل',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.history, color: Colors.black, size: 24.sp),
                            ],
                          ),

                          SizedBox(height: 30.h),

                          // حذف الكل
                          Obx(
                            () => historyController.historyRecords.isEmpty
                                ? const SizedBox()
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () => historyController.showDeleteAllConfirmation(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ✅ كلمة "حذف الكل" أولاً
                                          Text(
                                            'حذف الكل',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          // ✅ علامة X بعد كلمة "حذف الكل"
                                          Container(
                                            width: 24.w,
                                            height: 24.h,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
 
                    // ── Body ──
                    Expanded(
                      child: historyController.historyRecords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 80.sp, color: const Color(0xFF30BBF9)),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد سجلات',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 11.w),
                              itemCount: historyController.historyRecords.length,
                              itemBuilder: (context, index) {
                                final record = historyController.historyRecords[index];
                                return _buildHistoryCard(record, historyController);
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
 
  Widget _buildHistoryCard(
    HistoryRecord record,
    HistoryController historyController,
  ) {
    return Obx(() {
      final isPlaying = historyController.playingId.value == record.id;
 
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF5DBBFF), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Row: حذف | play | نص الجملة ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // نص الجملة
                Expanded(
                  child: Text(
                    record.formedSentence,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF2BBBFB),
                    ),
                  ),
                ),
                SizedBox(width: 17.w),
                // زرار الصوت ✅ بلون أسود ثابت
                GestureDetector(
                  onTap: () => historyController.playAudio(record),
                  child: historyController.isLoadingAudio.value && isPlaying
                      ? SizedBox(
                          width: 31.w,
                          height: 31.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF248DBC),
                          ),
                        )
                      : SvgPicture.asset(
                          AppAssets.MicLine,
                          width: 31.w,
                          height: 31.h,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
                SizedBox(width: 17.w),
                // زرار الحذف
                GestureDetector(
                  onTap: () => historyController.showDeleteConfirmation(record.id),
                  child: Container(
                    width: 85.w,
                    height: 35.h,
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'حذف',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            // ── التاريخ ──
            Text(
              _formatDate(record.formedAt),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: const Color(0xFF484848),
              ),
            ),
          ],
        ),
      );
    });
  }
 
  String _formatDate(DateTime dateTime) {
    final DateTime utcTime = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
    final DateTime egyptTime = utcTime.add(const Duration(hours: 3));
    return DateFormat('yyyy-MM-dd   hh:mm a').format(egyptTime);
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/core/widgets/primary_button.dart';

class HowToUseScreenBody extends StatefulWidget {
  const HowToUseScreenBody({super.key});

  @override
  State<HowToUseScreenBody> createState() => _HowToUseScreenBodyState();
}

class _HowToUseScreenBodyState extends State<HowToUseScreenBody> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPicking = false;
  String? _error;
  String? _fileName;

  Future<void> _pickVideo() async {
    setState(() {
      _isPicking = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _isPicking = false);
        return;
      }

      final path = result.files.single.path!;
      final name = result.files.single.name;

      await _controller?.dispose();
      setState(() {
        _isInitialized = false;
        _fileName = name;
      });

      _controller = VideoPlayerController.file(File(path));
      await _controller!.initialize();
      _controller!.addListener(_onVideoUpdate);

      setState(() => _isInitialized = true);
      _controller!.play();
    } catch (e) {
      setState(() => _error = 'تعذّر تحميل الفيديو: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          children: [
            // ── Title ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                'كيفية الاستخدام',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ── Video Box ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFF5DBBFF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: _buildVideoContent(),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── اسم الفيديو ──
                    if (_fileName != null)
                      Text(
                        _fileName!,
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 12.h),

                    // ── Controls ──
                    if (_isInitialized && _controller != null) ...[
                      // شريط التقدم
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6.r),
                          trackHeight: 3.h,
                          activeTrackColor: AppColors.primaryColor,
                          inactiveTrackColor:
                              const Color(0xFF5DBBFF).withOpacity(0.3),
                          thumbColor: AppColors.primaryColor,
                          overlayColor:
                              AppColors.primaryColor.withOpacity(0.15),
                        ),
                        child: Slider(
                          min: 0,
                          max: _controller!.value.duration.inSeconds.toDouble(),
                          value: _controller!.value.position.inSeconds
                              .toDouble()
                              .clamp(
                                0,
                                _controller!.value.duration.inSeconds.toDouble(),
                              ),
                          onChanged: (v) =>
                              _controller!.seekTo(Duration(seconds: v.toInt())),
                        ),
                      ),

                      // الوقت
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller!.value.duration),
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12.sp),
                            ),
                            Text(
                              _formatDuration(_controller!.value.position),
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Play/Pause + زرار اختيار فيديو جديد
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _isPicking ? null : _pickVideo,
                            child: Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF276C8A),
                                shape: BoxShape.circle,
                              ),
                              child: _isPicking
                                  ? Padding(
                                      padding: EdgeInsets.all(12.r),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.folder_open_rounded,
                                      color: Colors.white, size: 22.w),
                            ),
                          ),

                          SizedBox(width: 24.w),

                          // Play/Pause
                          GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]

                    // ── لو لسه مفيش فيديو ──
                    else if (!_isPicking && !_isInitialized && _error == null)
                      GestureDetector(
                        onTap: _pickVideo,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open_rounded,
                                  color: Colors.white, size: 20.w),
                              SizedBox(width: 8.w),
                              Text(
                                'اختار فيديو من الجهاز',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── زرار الرجوع ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: PrimaryButton(
                buttonText: 'الرجوع',
                buttonColor: AppColors.primaryColor,
                width: 272.w,
                height: 65.h,
                onPress: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_error != null) {
      return Container(
        height: 220.h,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40.w),
              SizedBox(height: 8.h),
              Text(
                _error!,
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: _pickVideo,
                child: Text(
                  'حاول مرة أخرى',
                  style: TextStyle(
                    color: const Color(0xFF30BBF9),
                    fontSize: 13.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isPicking || (!_isInitialized && _fileName != null)) {
      return Container(
        height: 220.h,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF30BBF9)),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 220.h,
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            color: Colors.white24,
            size: 64.w,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
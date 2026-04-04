import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/core/widgets/custom_round_button.dart';
import 'package:graduationproject/core/widgets/primary_button.dart';
import 'package:graduationproject/features/voicetosign_screen/presentation_layer/voicetosignscreenview.dart';

// ─────────────────────────────────────────
// Models
// ─────────────────────────────────────────

class TextToSignResponse {
  final String? errorMessage;
  final List<List<String>> data;
  final bool success;
  final int statusCode;

  TextToSignResponse({
    this.errorMessage,
    required this.data,
    required this.success,
    required this.statusCode,
  });

  factory TextToSignResponse.fromJson(Map<String, dynamic> json) {
    List<List<String>> parsedData = [];
    if (json['data'] != null) {
      final rawData = json['data'] as List<dynamic>;
      parsedData = rawData.map((item) {
        if (item is List) {
          return item.map((e) => e.toString()).toList();
        }
        return [item.toString()];
      }).toList();
    }
    return TextToSignResponse(
      errorMessage: json['errorMessage'],
      data: parsedData,
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

// ─────────────────────────────────────────
// Service
// ─────────────────────────────────────────

class TextToSignService {
  static const String _baseUrl = 'https://backup.ema2a.website';

  static Future<TextToSignResponse> convertTextToSign(String sentence) async {
    final url = Uri.parse('$_baseUrl/api/ArabicLanguageTranslator/text-to-sign');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'Text': sentence}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return TextToSignResponse.fromJson(jsonData);
    } else {
      throw Exception('فشل الاتصال: ${response.statusCode} - ${response.body}');
    }
  }
}

// ─────────────────────────────────────────
// Helper: decode base64 image string safely
// ─────────────────────────────────────────

Uint8List _decodeBase64Image(String raw) {
  final cleaned = raw.contains(',') ? raw.split(',').last : raw;
  return base64Decode(cleaned);
}

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────

class TextToSignScreenBody extends StatefulWidget {
  const TextToSignScreenBody({super.key});

  @override
  State<TextToSignScreenBody> createState() => _TextToSignScreenBodyState();
}

class _TextToSignScreenBodyState extends State<TextToSignScreenBody> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  String? _errorText;
  TextToSignResponse? _response;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _convertText() async {
    FocusScope.of(context).unfocus();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'من فضلك اكتب نص أولاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _response = null;
    });

    try {
      final result = await TextToSignService.convertTextToSign(text);
      setState(() => _response = result);

      if (!result.success || result.data.isEmpty) {
        setState(() => _errorText = result.errorMessage ?? 'حدث خطأ غير معروف');
      }
    } catch (e) {
      setState(() => _errorText = 'حدث خطأ في الاتصال: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                'تحويل النص الى لغة الاشارة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Text Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                height: 110.h,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9).withOpacity(0.42),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF5DBBFF),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'اكتب.....',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(
                      color: const Color(0xFFA9A9A9),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // Buttons Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomRoundButton(
                      buttonText: 'تسجيل صوتي',
                      icon: SvgPicture.asset(
                        AppAssets.MicLine,
                        width: 18.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      textColor: Colors.white,
                      buttonColor: AppColors.primaryColor,
                      borderColor: AppColors.primaryColor,
                      height: 48.h,
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VoiceToSignScreenView(),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: CustomRoundButton(
                      buttonText: 'تحويل النص',
                      icon: _isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.spellcheck,
                              color: Colors.white,
                              size: 18.w,
                            ),
                      textColor: Colors.white,
                      buttonColor: const Color(0xFF276C8A),
                      borderColor: const Color(0xFF44BCF0),
                      height: 48.h,
                      onPress: _isLoading ? () {} : _convertText,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Result Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Error
                    if (_errorText != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Results Cards
                    if (_response != null &&
                        _response!.success &&
                        _response!.data.isNotEmpty)
                      Column(
                        children: _response!.data.asMap().entries.map((wordEntry) {
                          final wordIndex = wordEntry.key;
                          final images = wordEntry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFF5DBBFF),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.spellcheck,
                                        color: const Color(0xFF30BBF9),
                                        size: 18.w,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'كلمة ${wordIndex + 1}',
                                        style: TextStyle(
                                          color: const Color(0xFF30BBF9),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 10.h),

                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: SizedBox(
                                      height: 88.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        reverse: true,
                                        itemCount: images.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 12.w),
                                        itemBuilder: (context, imgIndex) {
                                          return Container(
                                            width: 80.w,
                                            height: 80.h,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF98DCFA),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: _buildSignImage(images[imgIndex]),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 25.h),

                    PrimaryButton(
                      buttonText: 'الرجوع',
                      buttonColor: AppColors.primaryColor,
                      width: 272.w,
                      height: 65.h,
                      onPress: () => Navigator.pop(context),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignImage(String raw) {
    try {
      final bytes = _decodeBase64Image(raw);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } catch (_) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }
}
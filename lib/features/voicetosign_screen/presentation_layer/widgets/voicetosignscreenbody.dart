// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/style/app_colors.dart';
import 'package:graduationproject/core/widgets/custom_round_button.dart';
import 'package:graduationproject/core/widgets/primary_button.dart';
import 'package:graduationproject/features/texttosign_screen/presentation_layer/texttosignscreenview.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────
// Web Audio Recorder
// ─────────────────────────────────────────

class _WebRecorder {
  html.MediaRecorder? _mr;
  html.MediaStream? _stream;
  final List<html.Blob> _chunks = [];

  Future<bool> requestPermission() async {
    try {
      _stream = await html.window.navigator.getUserMedia(audio: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> start() async {
    _chunks.clear();
    _stream ??= await html.window.navigator.getUserMedia(audio: true);
    _mr = html.MediaRecorder(_stream!);
    _mr!.addEventListener('dataavailable', (e) {
      final blob = (e as html.BlobEvent).data;
      if (blob != null && blob.size > 0) _chunks.add(blob);
    });
    _mr!.start();
  }

  Future<Uint8List?> stop() async {
    if (_mr == null) return null;
    _mr!.requestData();
    await Future.delayed(const Duration(milliseconds: 150));
    _mr!.stop();
    await Future.delayed(const Duration(milliseconds: 300));
    if (_chunks.isEmpty) return null;
    final blob = html.Blob(_chunks, 'audio/webm');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    return reader.result as Uint8List?;
  }

  void dispose() {
    try {
      _mr?.stop();
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
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
// Service
// ─────────────────────────────────────────

class _ApiService {
  static const _base = 'https://backup.ema2a.website';

  static Future<String> _audioToText(Uint8List bytes) async {
    final res = await http.post(
      Uri.parse('$_base/api/ArabicLanguageTranslator/audio-to-text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'AudioData': base64Encode(bytes),
        'MimeType': 'audio/webm',
      }),
    );
    if (res.statusCode != 200) throw Exception('فشل تحويل الصوت: ${res.statusCode}');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['success'] != true) throw Exception(json['errorMessage'] ?? 'خطأ');
    final text = json['data']?.toString().trim() ?? '';
    if (text.isEmpty) throw Exception('لم يُتعرَّف على كلام في التسجيل');
    return text;
  }

  static Future<List<List<String>>> _textToSign(String text) async {
    final res = await http.post(
      Uri.parse('$_base/api/ArabicLanguageTranslator/text-to-sign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Text': text}),
    );
    if (res.statusCode != 200) throw Exception('فشل تحويل النص: ${res.statusCode}');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['success'] != true) throw Exception(json['errorMessage'] ?? 'خطأ');
    final raw = json['data'];
    if (raw == null) return [];
    if (raw is List) {
      return raw.map<List<String>>((item) {
        if (item is List) return item.map((e) => e.toString()).toList();
        return [item.toString()];
      }).toList();
    }
    return [];
  }

  static Future<List<List<String>>> voiceToSign(Uint8List bytes) async {
    final text = await _audioToText(bytes);
    return _textToSign(text);
  }
}

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────

class VoiceToSignScreenBody extends StatefulWidget {
  const VoiceToSignScreenBody({super.key});
  @override
  State<VoiceToSignScreenBody> createState() => _State();
}

class _State extends State<VoiceToSignScreenBody>
    with SingleTickerProviderStateMixin {
  final _recorder = _WebRecorder();

  bool _isRecording = false;
  bool _isLoading = false;
  String? _error;
  List<List<String>> _signImages = [];
  String _loadingStep = '';

  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onMicTap() async {
    if (_isLoading) return;
    if (_isRecording) {
      final bytes = await _recorder.stop();
      setState(() => _isRecording = false);
      if (bytes == null || bytes.isEmpty) {
        setState(() => _error = 'لم يُسجَّل صوت، حاول مرة أخرى');
        return;
      }
      await _convert(bytes);
    } else {
      final ok = await _recorder.requestPermission();
      if (!ok) {
        setState(() => _error = 'اسمح للمتصفح باستخدام الميكروفون');
        return;
      }
      await _recorder.start();
      setState(() {
        _isRecording = true;
        _error = null;
        _signImages = [];
      });
    }
  }

  Future<void> _convert(Uint8List bytes) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _signImages = [];
      _loadingStep = 'جاري التعرف على الكلام...';
    });
    try {
      final images = await _ApiService.voiceToSign(bytes);
      setState(() => _signImages = images);
      if (images.isEmpty) setState(() => _error = 'لا توجد إشارات لهذا الكلام');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
        _loadingStep = '';
      });
    }
  }

  Widget _buildSignImage(String raw) {
    try {
      final bytes = _decodeBase64Image(raw);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } catch (_) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }
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
                'تحويل الصوت الى لغة الاشارة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // ── Mic Section ──
            GestureDetector(
              onTap: _onMicTap,
              child: SizedBox(
                width: double.infinity,
                height: 180.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 20.w,
                      child: _buildWaves(mirrored: false),
                    ),
                    Positioned(
                      right: 20.w,
                      child: _buildWaves(mirrored: true),
                    ),
                    Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB8E4F9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    ScaleTransition(
                      scale: _isRecording
                          ? _scale
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red
                              : const Color(0xFF30BBF9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isRecording
                              ? Icon(Icons.stop_rounded,
                                  color: Colors.white, size: 50.w)
                              : SvgPicture.asset(
                                  AppAssets.MicVoice,
                                  width: 52.w,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // ── Status ──
            if (_isRecording)
              Text('🔴 جاري التسجيل... اضغط للإيقاف',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500))
            else if (_isLoading)
              Text(_loadingStep,
                  style:
                      TextStyle(color: const Color(0xFF2BBBFA), fontSize: 13.sp))
            else
              Text('اضغط للتسجيل',
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp)),

            SizedBox(height: 14.h),

            // ── Buttons Row ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomRoundButton(
                      buttonText: _isRecording ? 'إيقاف' : 'تسجيل صوتي',
                      icon: _isRecording
                          ? Icon(Icons.stop, color: Colors.white, size: 18.w)
                          : SvgPicture.asset(
                              AppAssets.MicLine,
                              width: 18.w,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                      textColor: Colors.white,
                      buttonColor:
                          _isRecording ? Colors.red : AppColors.primaryColor,
                      borderColor:
                          _isRecording ? Colors.red : AppColors.primaryColor,
                      height: 48.h,
                      onPress: _isLoading ? () {} : _onMicTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomRoundButton(
                      buttonText: 'تحويل النص',
                      icon: Icon(Icons.spellcheck,
                          color: Colors.white, size: 18.w),
                      textColor: Colors.white,
                      buttonColor: const Color(0xFF276C8A),
                      borderColor: const Color(0xFF44BCF0),
                      height: 48.h,
                      onPress: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TextToSignScreenView()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Results ──
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(children: [
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(_loadingStep,
                          style: TextStyle(
                              color: const Color(0xFF2BBBFA), fontSize: 14.sp)),
                    ),

                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ),

                  if (_signImages.isNotEmpty)
                    Column(
                      children: _signImages.asMap().entries.map((e) {
                        final idx = e.key;
                        final imgs = e.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF5DBBFF), width: 1),
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
                                    Icon(Icons.spellcheck,
                                        color: const Color(0xFF30BBF9),
                                        size: 18.w),
                                    SizedBox(width: 4.w),
                                    Text('كلمة ${idx + 1}',
                                        style: TextStyle(
                                            color: const Color(0xFF30BBF9),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600)),
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
                                      itemCount: imgs.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 12.w),
                                      itemBuilder: (_, i) => Container(
                                        width: 80.w,
                                        height: 80.h,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF98DCFA),
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                              BorderRadius.circular(12),
                                          child: _buildSignImage(imgs[i]),
                                        ),
                                      ),
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
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaves({required bool mirrored}) {
    final heights = [40.h, 65.h, 85.h, 65.h, 40.h];
    final bars = List.generate(5, (i) {
      return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final factor = _isRecording
              ? (0.4 + 0.6 * ((_anim.value + i * 0.2) % 1.0))
              : 0.3;
          return Container(
            width: 4.w,
            height: heights[i] * factor,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF5DBBFF).withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: mirrored ? bars.reversed.toList() : bars,
    );
  }
}
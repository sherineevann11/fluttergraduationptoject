import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:graduationproject/features/auth/services/history_service.dart';
import 'package:graduationproject/features/history_screen/presentation_layer/widgets/audio_playing_overlay.dart';

class HistoryRecord {
  final int id;
  final String formedSentence;
  final DateTime formedAt;
  String? audioUrl; // رابط حقيقي من السيرفر (لو موجود)
  Uint8List? cachedAudioBytes; // كاش للصوت اللي تولّد محليًا (يعمل على ويب وموبايل)

  HistoryRecord({
    required this.id,
    required this.formedSentence,
    required this.formedAt,
    this.audioUrl,
    this.cachedAudioBytes,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'] ?? 0,
      formedSentence: json['formedSentence'] ?? '',
      formedAt: DateTime.parse(json['formedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class HistoryController extends GetxController {
  final HistoryService _service = HistoryService();
  final _box = GetStorage();
  AudioPlayer? _currentPlayer; // بيتم إنشاء واحد جديد لكل تشغيل عشان نتجنب مشاكل الويب
  bool _isProcessingAudio = false; // قفل لمنع تشغيل متزامن/متكرر يسبب Race Condition
  bool _isOverlayShowing = false; // تتبّع حالة عرض شاشة "بيتشغل دلوقتي"

  var isLoading = false.obs;
  var historyRecords = <HistoryRecord>[].obs;
  var errorMessage = ''.obs;
  var playingId = Rxn<int>();
  var isLoadingAudio = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserHistory();
  }

  @override
  void onClose() {
    _currentPlayer?.dispose();
    super.onClose();
  }

  /// يوقف ويتخلّص من الـ player الحالي بأمان (لو موجود)
  Future<void> _disposeCurrentPlayer() async {
    final player = _currentPlayer;
    _currentPlayer = null;
    if (player != null) {
      try {
        await player.stop();
      } catch (_) {
        // ممكن يكون already disposed - نتجاهل بأمان
      }
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  /// يظهر عرض "بيتشغل دلوقتي" (المايك + خطوط الصوت المتحركة)
  void _showPlayingOverlay() {
    if (_isOverlayShowing) return;
    _isOverlayShowing = true;
    Get.dialog(
      const AudioPlayingOverlay(),
      barrierDismissible: true, // الضغط برّا المربع بيوقف الصوت ويقفل العرض
      barrierColor: Colors.black.withOpacity(0.25),
    ).then((_) {
      _isOverlayShowing = false;
      // لو المستخدم قفل العرض بالضغط برّا والصوت لسه شغال -> وقفه
      if (playingId.value != null) {
        _disposeCurrentPlayer();
        playingId.value = null;
      }
    });
  }

  /// يقفل عرض "بيتشغل دلوقتي" لو ظاهر حاليًا
  void _hidePlayingOverlay() {
    if (!_isOverlayShowing) return;
    _isOverlayShowing = false;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String _parseErrorMessage(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
          return 'انتهت مهلة الاتصال - يرجى التحقق من الإنترنت أو المحاولة لاحقاً';
        case dio.DioExceptionType.receiveTimeout:
          return 'استغرقت العملية وقتاً طويلاً - يرجى المحاولة لاحقاً';
        case dio.DioExceptionType.sendTimeout:
          return 'فشل إرسال البيانات - يرجى التحقق من الإنترنت';
        case dio.DioExceptionType.badResponse:
          return 'خطأ من الخادم (${error.response?.statusCode})';
        case dio.DioExceptionType.cancel:
          return 'تم إلغاء العملية';
        default:
          return 'حدث خطأ في الاتصال';
      }
    }
    return error.toString();
  }

  Future<void> fetchUserHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _box.read('accessToken') ?? '';
      if (token.isEmpty) {
        errorMessage.value = 'يرجى تسجيل الدخول أولاً';
        isLoading.value = false;
        return;
      }

      final response = await _service.getUserHistory(token);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          historyRecords.value = (data as List)
              .map(
                (item) => HistoryRecord.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final recordsList = data['data'] as List;
          historyRecords.value = recordsList
              .map(
                (item) => HistoryRecord.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } else {
        errorMessage.value = 'خطأ في تحميل السجل';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Fetch History Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRecord(int recordId) async {
    try {
      final token = _box.read('accessToken') ?? '';
      if (token.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى تسجيل الدخول أولاً',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _service.deleteHistoryRecord(token, recordId);

      if (response.statusCode == 200) {
        historyRecords.removeWhere((record) => record.id == recordId);
        Get.snackbar(
          'نجاح',
          'تم حذف السجل',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حذف السجل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e);
      Get.snackbar(
        'خطأ',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Delete Record Error: $e");
    }
  }

  Future<void> deleteAllHistory() async {
    try {
      final token = _box.read('accessToken') ?? '';
      if (token.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى تسجيل الدخول أولاً',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _service.deleteAllHistory(token);

      if (response.statusCode == 200) {
        historyRecords.clear();
        Get.snackbar(
          'نجاح',
          'تم حذف جميع السجلات',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حذف السجلات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e);
      Get.snackbar(
        'خطأ',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Delete All History Error: $e");
    }
  }

  /// تشغيل الصوت - شغالة على الويب والموبايل والديسكتوب بدون أي فرق في الكود
  /// (مفيش File ولا path_provider، الصوت بيتشغّل مباشرة من البايتات في الميموري)
  Future<void> playAudio(HistoryRecord record) async {
    // ✅ منع أي ضغطة جديدة لو في عملية تشغيل/تحميل صوت شغالة حاليًا
    if (_isProcessingAudio) return;
    _isProcessingAudio = true;

    try {
      // لو نفس السجل شغال حاليًا -> وقفه
      if (playingId.value == record.id) {
        await _disposeCurrentPlayer();
        playingId.value = null;
        _hidePlayingOverlay();
        return;
      }

      // ✅ اظهر عرض "بيتشغل دلوقتي" فورًا (يغطي وقت التحميل والتشغيل مع بعض)
      _showPlayingOverlay();

      String? urlToPlay;
      Uint8List? bytesToPlay;

      // لو في رابط حقيقي جاي من السيرفر
      if (record.audioUrl != null && record.audioUrl!.isNotEmpty) {
        urlToPlay = record.audioUrl;
      }
      // لو الصوت متولّد ومخزّن في الكاش بالفعل
      else if (record.cachedAudioBytes != null) {
        bytesToPlay = record.cachedAudioBytes;
      }
      // مفيش حاجة جاهزة -> هات الصوت من السيرفر
      else {
        isLoadingAudio.value = true;
        final token = _box.read('accessToken') ?? '';
        if (token.isEmpty) {
          Get.snackbar('خطأ', 'يرجى تسجيل الدخول أولاً',
              backgroundColor: Colors.red, colorText: Colors.white);
          _hidePlayingOverlay();
          return;
        }

        final response = await _service.generateAudio(token, record.formedSentence);

        if (response.statusCode == 200) {
          final result = response.data;
          if (result['success'] == true) {
            final String base64Audio = result['data']['audioData'];
            final int sampleRate = result['data']['sampleRate'];
            final Uint8List pcmBytes = base64Decode(base64Audio);
            final Uint8List wavBytes = _addWavHeader(pcmBytes, sampleRate);

            // كاش البايتات في الـ record نفسه (يفيد لو شغّله تاني)
            record.cachedAudioBytes = wavBytes;
            bytesToPlay = wavBytes;
          } else {
            Get.snackbar('خطأ', 'فشل توليد الصوت',
                backgroundColor: Colors.red, colorText: Colors.white);
            _hidePlayingOverlay();
            return;
          }
        } else {
          Get.snackbar('خطأ', 'فشل توليد الصوت',
              backgroundColor: Colors.red, colorText: Colors.white);
          _hidePlayingOverlay();
          return;
        }
      }

      // ✅ نتخلّص من أي player قديم تمامًا، ونعمل واحد جديد نظيف لكل تشغيل
      await _disposeCurrentPlayer();

      final newPlayer = AudioPlayer();
      newPlayer.onPlayerComplete.listen((_) {
        if (playingId.value == record.id) {
          playingId.value = null;
        }
        _hidePlayingOverlay();
      });
      _currentPlayer = newPlayer;
      playingId.value = record.id;

      if (urlToPlay != null) {
        await newPlayer.play(UrlSource(urlToPlay));
      } else if (bytesToPlay != null) {
        await newPlayer.play(BytesSource(bytesToPlay));
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e);
      Get.snackbar('خطأ', 'خطأ في تشغيل الصوت: $errorMsg',
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Play Audio Error: $e");
      _hidePlayingOverlay();
    } finally {
      isLoadingAudio.value = false;
      _isProcessingAudio = false;
    }
  }

  Uint8List _addWavHeader(Uint8List pcmBytes, int sampleRate) {
    final int channels = 1;
    final int bytesPerSample = 2;
    final int byteRate = sampleRate * channels * bytesPerSample;
    final int blockAlign = channels * bytesPerSample;

    final header = BytesBuilder();
    header.addByte(82);
    header.addByte(73);
    header.addByte(70);
    header.addByte(70);
    header.addByte((pcmBytes.length + 36) & 0xFF);
    header.addByte(((pcmBytes.length + 36) >> 8) & 0xFF);
    header.addByte(((pcmBytes.length + 36) >> 16) & 0xFF);
    header.addByte(((pcmBytes.length + 36) >> 24) & 0xFF);
    header.addByte(87);
    header.addByte(65);
    header.addByte(86);
    header.addByte(69);
    header.addByte(102);
    header.addByte(109);
    header.addByte(116);
    header.addByte(32);
    header.addByte(16);
    header.addByte(0);
    header.addByte(0);
    header.addByte(0);
    header.addByte(1);
    header.addByte(0);
    header.addByte(channels);
    header.addByte(0);
    header.addByte(sampleRate & 0xFF);
    header.addByte((sampleRate >> 8) & 0xFF);
    header.addByte((sampleRate >> 16) & 0xFF);
    header.addByte((sampleRate >> 24) & 0xFF);
    header.addByte(byteRate & 0xFF);
    header.addByte((byteRate >> 8) & 0xFF);
    header.addByte((byteRate >> 16) & 0xFF);
    header.addByte((byteRate >> 24) & 0xFF);
    header.addByte(blockAlign);
    header.addByte(0);
    header.addByte(16);
    header.addByte(0);
    header.addByte(100);
    header.addByte(97);
    header.addByte(116);
    header.addByte(97);
    header.addByte(pcmBytes.length & 0xFF);
    header.addByte((pcmBytes.length >> 8) & 0xFF);
    header.addByte((pcmBytes.length >> 16) & 0xFF);
    header.addByte((pcmBytes.length >> 24) & 0xFF);
    header.add(pcmBytes);

    return header.toBytes();
  }

  void showDeleteConfirmation(int recordId) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      content: const Text('هل تريد حذف هذا السجل؟'),
      confirm: ElevatedButton(
        onPressed: () {
          deleteRecord(recordId);
          Get.back();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('حذف', style: TextStyle(color: Colors.white)),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('إلغاء'),
      ),
    );
  }

  void showDeleteAllConfirmation() {
    Get.defaultDialog(
      title: 'تأكيد حذف الكل',
      content: const Text('هل تريد حذف جميع السجلات؟'),
      confirm: ElevatedButton(
        onPressed: () {
          deleteAllHistory();
          Get.back();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('حذف', style: TextStyle(color: Colors.white)),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('إلغاء'),
      ),
    );
  }
}
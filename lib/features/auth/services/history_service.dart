import 'package:dio/dio.dart' as dio;

class HistoryService {
  late final dio.Dio _dio;

  HistoryService() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: "https://backup.ema2a.website/api",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  dio.Options _authOptions(String token) {
    return dio.Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      validateStatus: (status) => status != null && status < 500,
    );
  }

  Future<dio.Response> getUserHistory(String token) async {
    try {
      final response = await _dio.get(
        "/UserHistory/get-user-history",
        options: _authOptions(token),
      );
      return response;
    } on dio.DioException catch (e) {
      print("Get History Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<dio.Response> deleteHistoryRecord(String token, int recordId) async {
    try {
      final response = await _dio.delete(
        "/UserHistory/delete-user-history-record",
        options: _authOptions(token),
        data: {"Id": recordId},
      );
      return response;
    } on dio.DioException catch (e) {
      print("Delete Record Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<dio.Response> deleteAllHistory(String token) async {
    try {
      final response = await _dio.delete(
        "/UserHistory/delete-all-user-history",
        options: _authOptions(token),
      );
      return response;
    } on dio.DioException catch (e) {
      print("Delete All History Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<dio.Response> generateAudio(String token, String text) async {
    try {
      final response = await _dio.post(
        "/signlanguagetranslator/generate-audio",
        options: _authOptions(token),
        data: {"text": text},
      );
      return response;
    } on dio.DioException catch (e) {
      print("Generate Audio Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? e.message);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:quho_app/core/config/environment.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/network/interceptors/auth_interceptor.dart';
import 'package:quho_app/core/network/interceptors/error_interceptor.dart';
import 'package:quho_app/core/network/interceptors/logging_interceptor.dart';

/// Cliente HTTP principal para QUHO
/// Configura Dio con interceptores y configuración base
class ApiClient {
  late final Dio _dio;

  Dio get dio => _dio;

  ApiClient({
    String? baseUrl,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? EnvironmentConfig.apiBaseUrl,
        connectTimeout: EnvironmentConfig.connectionTimeout,
        receiveTimeout: EnvironmentConfig.connectionTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores
    _dio.interceptors.addAll([
      AuthInterceptor(_dio),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart upload (para imágenes, archivos, etc.)
  Future<Response> uploadFile(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? data,
  }) async {
    final formData = FormData.fromMap({
      ...?data,
      fieldName: await MultipartFile.fromFile(filePath),
    });

    return await _dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  // Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}


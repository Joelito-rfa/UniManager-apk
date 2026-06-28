import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/course_resource_model.dart';

class CourseResourceState {
  final List<CourseResourceModel> resources;
  final bool isLoading;
  final String? error;

  const CourseResourceState({
    this.resources = const [],
    this.isLoading = false,
    this.error,
  });

  CourseResourceState copyWith({
    List<CourseResourceModel>? resources,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CourseResourceState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CourseResourceNotifier extends StateNotifier<CourseResourceState> {
  final DioClient _dioClient;

  CourseResourceNotifier(this._dioClient) : super(const CourseResourceState());

  Future<void> loadResources(String endpoint) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get(endpoint);
      final data = response.data;
      final list = (data['data'] as List)
          .map((json) => CourseResourceModel.fromJson(json))
          .toList();
      state = CourseResourceState(resources: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadResource(String endpoint, {
    required String title,
    required String type,
    String? description,
    String? url,
    int? duration,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('type', type),
        if (description != null) MapEntry('description', description),
        if (duration != null) MapEntry('duration', duration.toString()),
        if (url != null) MapEntry('url', url),
      ]);
      if (fileBytes != null) {
        formData.files.add(MapEntry('file', MultipartFile.fromBytes(fileBytes, filename: fileName)));
      } else if (filePath != null) {
        formData.files.add(MapEntry('file', await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('\\').last.split('/').last,
        )));
      }
      final response = await _dioClient.post(endpoint, data: formData);
      final result = response.data;
      if (result['success'] == true) {
        await loadResources(endpoint);
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      final errorMsg = e is DioException && e.response?.data is Map
          ? (e.response!.data['message'] ?? (e.response!.data['errors'] is Map
              ? (e.response!.data['errors'] as Map).values.expand((v) => v is List ? v : [v]).join('\n')
              : e.toString()))
          : e.toString();
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  Future<bool> deleteResource(String endpoint) async {
    try {
      final response = await _dioClient.delete(endpoint);
      final result = response.data;
      return result['success'] == true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<File?> downloadResource(String endpoint, String savePath) async {
    try {
      final file = await _dioClient.download(endpoint, savePath);
      return file;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

}

final courseResourceProvider =
    StateNotifierProvider.family<CourseResourceNotifier, CourseResourceState, String>((ref, endpoint) {
  final dioClient = ref.read(dioClientProvider);
  return CourseResourceNotifier(dioClient);
});

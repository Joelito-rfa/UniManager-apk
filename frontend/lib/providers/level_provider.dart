import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/level_model.dart';

final allLevelsProvider = FutureProvider<List<LevelModel>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  final response = await dioClient.get(
    ApiConstants.levelsList,
    queryParameters: {'per_page': -1},
  );
  final data = response.data;
  if (data['success'] == true) {
    final rawData = data['data'];
    List<dynamic> items;
    if (rawData is List) {
      items = rawData;
    } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      items = rawData['data'] as List<dynamic>;
    } else {
      items = [];
    }
    final levels = items.map((e) => LevelModel.fromJson(e)).toList();
    final seenIds = <int>{};
    return levels.where((l) => seenIds.add(l.id)).toList();
  }
  return [];
});

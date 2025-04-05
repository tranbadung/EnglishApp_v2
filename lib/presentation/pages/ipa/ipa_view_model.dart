import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_up/presentation/pages/admin/database/model/phonetic_model.dart' as model;

  import 'package:speak_up/presentation/pages/ipa/ipa_state.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import 'package:speak_up/domain/entities/phonetic/phonetic.dart' as entity;

 import '../admin/database/database_helper.dart';

class IpaViewModel extends StateNotifier<IpaState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  IpaViewModel() : super(const IpaState());

  entity.Phonetic _convertToEntity(model.Phonetic model) {
    Map<String, String> exampleMap = {};
    try {
      // Remove any whitespace and curly braces
      String cleanExample =
      model.example.trim().replaceAll('{', '').replaceAll('}', '');

      // Split the string by commas to get individual key-value pairs
      List<String> pairs = cleanExample.split(',');

      for (String pair in pairs) {
        pair = pair.trim();
        if (pair.contains(':')) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            // Remove quotes and whitespace from key and value
            String key = parts[0].trim().replaceAll('"', '');
            String value = parts[1].trim().replaceAll('"', '');
            exampleMap[key] = value;
          }
        } else if (pair.isNotEmpty) {
          exampleMap[pair] = '';
        }
      }
    } catch (e) {
      print('Error parsing example: $e');
      exampleMap[model.example] = '';
    }

    return entity.Phonetic(
      phoneticID: model.phoneticID ?? 0,
      phonetic: model.phonetic,
      phoneticType: model.phoneticType,
      youtubeVideoId: model.youtubeVideoId,
      example: exampleMap,
      description: model.description ?? '',
    );
  }

  Future<void> refreshData() async {
    print('Refreshing data...');
    state = state.copyWith(
      loadingStatus: LoadingStatus.loading,
      progressLoadingStatus: LoadingStatus.loading,
    );

    try {
      final phoneticList = await _databaseHelper.getAllPhonetics();
      print('Fetched ${phoneticList.length} phonetics from database');

      final vowels = phoneticList
          .where((p) => p.phoneticType == 1)
          .map(_convertToEntity)
          .toList();
      final consonants = phoneticList
          .where((p) => p.phoneticType == 2)
          .map(_convertToEntity)
          .toList();

      state = state.copyWith(
        loadingStatus: LoadingStatus.success,
        progressLoadingStatus: LoadingStatus.success,
        vowels: vowels,
        consonants: consonants,
        isDoneVowelList: List.generate(vowels.length, (index) => false),
        isDoneConsonantList: List.generate(consonants.length, (index) => false),
      );

      print('State updated with new data');
    } catch (e) {
      print('Error refreshing data: $e');
      state = state.copyWith(
        loadingStatus: LoadingStatus.error,
        progressLoadingStatus: LoadingStatus.error,
      );
    }
  }

  Future<void> updatePhonetic(entity.Phonetic phonetic) async {
    try {
      final modelPhonetic = model.Phonetic(
        phoneticID: phonetic.phoneticID,
        phonetic: phonetic.phonetic,
        phoneticType: phonetic.phoneticType,
        youtubeVideoId: phonetic.youtubeVideoId,
        example: phonetic.example.values.first,
        description: phonetic.description,
      );

      final success = await _databaseHelper.updatePhonetic(modelPhonetic);
      if (success) {
        await refreshData();
      }
    } catch (e) {
      print('Error updating phonetic: $e');
    }
  }
}

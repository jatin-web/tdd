import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/core/error/errors.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time user had internet connection
  ///
  /// Throws [CacheException] if no cached data is present
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel trivia);
}

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences preferences;
  NumberTriviaLocalDataSourceImpl(this.preferences);

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() async {
    final jsonString = preferences.getString('last_stored_trivia');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return NumberTriviaModel.fromJson(json);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel trivia) async {
    final jsonString = jsonEncode(trivia.toJson());
    preferences.setString('last_stored_trivia', jsonString);
    return;
  }
}

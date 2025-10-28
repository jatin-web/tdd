import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tdd_clean_architecture/core/error/errors.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../models/repositories/number_trivia_repository_impl_test.mocks.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockSharedPreferences;
  late NumberTriviaLocalDataSource numberTriviaLocalDataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSource = NumberTriviaLocalDataSourceImpl(
      mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    late NumberTriviaModel tNumberTriviaModel;
    setUp(() {
      tNumberTriviaModel = NumberTriviaModel(text: "Test", number: 1);
    });

    test(
      'should return last stored trivia from shared preferences, if stored',
      () async {
        // Arrange
        final tNumberTriviaJson = tNumberTriviaModel.toJson();
        String tNumberTriviaJsonString = jsonEncode(tNumberTriviaJson);
        when(
          mockSharedPreferences.getString('last_stored_trivia'),
        ).thenAnswer((_) => tNumberTriviaJsonString);

        // Act
        var result = await numberTriviaLocalDataSource.getLastNumberTrivia();

        expect(result, tNumberTriviaModel);
      },
    );

    test('should throw a cache exception, if no trivia stored', () async {
      // Arrange
      when(
        mockSharedPreferences.getString('last_stored_trivia'),
      ).thenReturn(null);

      // Act
      final call = numberTriviaLocalDataSource.getLastNumberTrivia;

      // Assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    late NumberTriviaModel tNumberTriviaModel;
    setUp(() {
      tNumberTriviaModel = NumberTriviaModel(text: "Test", number: 1);
    });
    test('should call shared preferences to cache the data', () {
      // Arrange
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) async => true);

      // Act
      numberTriviaLocalDataSource.cacheNumberTrivia(tNumberTriviaModel);

      // Assert
      final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
      verify(
        mockSharedPreferences.setString(
          'last_stored_trivia',
          expectedJsonString,
        ),
      );
    });
  });
}

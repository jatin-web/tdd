import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  late NumberTriviaModel numberTriviaModel;

  setUp(() {
    numberTriviaModel = NumberTriviaModel(number: 1, text: "Test Text");
  });

  test("should be a subclass of NumberTrivia Entity", () {
    expect(numberTriviaModel, isA<NumberTrivia>());
  });

  group("fromJson", () {
    test("should return a valid model when JSON number is an int", () {
      // Arrange
      Map<String, dynamic> jsonMap = jsonDecode(fixtureReader('trivia.json'));

      // Act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // Assert
      expect(result, numberTriviaModel);
    });

    test("should return a valid model when JSON number is a double", () {
      // Arrange
      Map<String, dynamic> jsonMap = jsonDecode(
        fixtureReader('trivia_double.json'),
      );

      // Act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // Assert
      expect(result, numberTriviaModel);
    });
  });

  group('toJson', () {
    test("should return a valid JSON", () {
      // Act
      final result = numberTriviaModel.toJson();

      // Assert
      Map<String, dynamic> expected = {"number": 1, "text": "Test Text"};
      expect(result, expected);
    });
  });
}

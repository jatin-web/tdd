import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/core/usecase/usecase.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import 'get_random_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository numberTriviaRepository;
  late GetRandomNumberTrivia useCase;
  setUp(() {
    numberTriviaRepository = MockNumberTriviaRepository();
    useCase = GetRandomNumberTrivia(numberTriviaRepository);
  });

  final tTrivia = NumberTrivia(text: "text", number: 1);

  test("Should get trivia for random number from the repository", () async {
    // Arrange
    when(
      numberTriviaRepository.getRandomNumberTrivia(),
    ).thenAnswer((_) async => Right(tTrivia));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(tTrivia));
    verify(numberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(numberTriviaRepository);
  });
}

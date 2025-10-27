import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_architecture/core/error/errors.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([
  NetworkInfo,
  NumberTriviaRemoteDataSource,
  NumberTriviaLocalDataSource,
])
void main() {
  // Repo we need to test
  late NumberTriviaRepositoryImpl repository;

  // Dependencies of Repo
  late MockNetworkInfo mockNetworkInfo;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group("device is online", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group("device is offline", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: "test trivia",
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestsOnline(() {
      test(
        "should return remote data when call to remote data source is successful",
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(any),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // Assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache data locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(any),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          await repository.getConcreteNumberTrivia(tNumber);

          // Assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return a Server Failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(any),
          ).thenThrow(ServerException());

          // Act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // Assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure([])));
        },
      );
    });

    runTestsOffline(() {
      test(
        "should return last locally cached trivia when cached data is present",
        () async {
          // Arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should return CacheFailure when no cached data is present",
        () async {
          // Arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());

          // Act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure([])));
        },
      );
    });
  });

  group("getRandomNumberTrivia", () {
    final tNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: "test trivia",
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestsOnline(() {
      test(
        "should return remote data when call to remote data source is successful",
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache data locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          await repository.getRandomNumberTrivia();

          // Assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return a Server Failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenThrow(ServerException());

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure([])));
        },
      );
    });

    runTestsOffline(() {
      test(
        "should return last locally cached trivia when cached data is present",
        () async {
          // Arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should return CacheFailure when no cached data is present",
        () async {
          // Arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure([])));
        },
      );
    });
  });
}

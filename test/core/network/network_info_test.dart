import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';
import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late MockInternetConnectionChecker mockInternetConnectionChecker;
  late NetworkInfoImpl networkInfoImpl;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(
      internetConnectionChecker: mockInternetConnectionChecker,
    );
  });

  group("isConnected", () {
    test('should forward the call to data connection checker', () async {
      // Arrange
      final tHasConnectionFuture = Future.value(true);
      when(
        mockInternetConnectionChecker.hasConnection,
      ).thenAnswer((_) => tHasConnectionFuture);

      // Act
      final result = networkInfoImpl.isConnected;

      // Assert
      verify(mockInternetConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });

    test('should return true when connected', () async {
      // Arrange
      when(
        mockInternetConnectionChecker.hasConnection,
      ).thenAnswer((_) async => true);

      // Act
      bool result = await networkInfoImpl.isConnected;

      //Assert
      expect(result, true);
    });
  });
}

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.properties);
  final List<Object?> properties;

  @override
  List<Object?> get props => properties;
}

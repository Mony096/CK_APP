import 'package:dartz/dartz.dart';
import '/core/error/failure.dart';

// Generic UseCase interface with Params class for multiple parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Params class to hold the parameters
class Params {
  final Map<String, dynamic> query;
  final dynamic id;

  Params({required this.query, required this.id});
}

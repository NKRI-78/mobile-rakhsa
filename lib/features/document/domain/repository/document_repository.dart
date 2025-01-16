import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';

abstract interface class DocumentRepository {
  Future<Either<Failure, void>> updateVisa({required String path});
  Future<Either<Failure, void>> deleteVisa();
  Future<Either<Failure, void>> updatePassport({required String path});
}
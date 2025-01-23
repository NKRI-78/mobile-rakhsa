import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/document/domain/repository/document_repository.dart';

class UpdatePassportUseCase {
  final DocumentRepository repository;

  UpdatePassportUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String userId,
    required String path
  }) async {
    return await repository.updatePassport(
      userId: userId,
      path: path
    );
  }
}
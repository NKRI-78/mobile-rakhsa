import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/document/domain/repository/document_repository.dart';

class UpdateVisaUseCase {
  final DocumentRepository repository;

  UpdateVisaUseCase(this.repository);

  Future<Either<Failure, void>> execute({required String path}) async {
    return await repository.updateVisa(path: path);
  }
}
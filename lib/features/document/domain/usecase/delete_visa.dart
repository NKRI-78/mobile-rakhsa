import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/document/domain/repository/document_repository.dart';

class DeleteVisaUseCase {
  final DocumentRepository repository;

  DeleteVisaUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    return await repository.deleteVisa();
  }
}
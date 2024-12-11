import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';

import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';

class GetVisaUseCase {
  final KbriRepository repository;

  GetVisaUseCase(this.repository);

  Future<Either<Failure, VisaContentModel>> execute({
    required String stateId,
  }) {
    return repository.infoVisa(
      stateId: stateId,
    );  
  }
}
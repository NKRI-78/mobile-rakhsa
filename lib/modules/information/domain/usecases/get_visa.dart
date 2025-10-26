import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/modules/information/data/models/visa.dart';

import 'package:rakhsa/modules/information/domain/repository/kbri_repository.dart';

class GetVisaUseCase {
  final KbriRepository repository;

  GetVisaUseCase(this.repository);

  Future<Either<Failure, VisaContentModel>> execute({required String stateId}) {
    return repository.infoVisa(stateId: stateId);
  }
}

import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/features/information/data/models/kbri.dart';

import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';

class GetKbriIdUseCase {
  final KbriRepository repository;

  GetKbriIdUseCase(this.repository);

  Future<Either<Failure, KbriInfoModel>> execute({required String stateId}) {
    return repository.infoKbriStateId(stateId: stateId);
  }
}

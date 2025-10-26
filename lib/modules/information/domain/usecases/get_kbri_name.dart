import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/modules/information/data/models/kbri.dart';

import 'package:rakhsa/modules/information/domain/repository/kbri_repository.dart';

class GetKbriNameUseCase {
  final KbriRepository repository;

  GetKbriNameUseCase(this.repository);

  Future<Either<Failure, KbriInfoModel>> execute({required String stateName}) {
    return repository.infoKbriStateName(stateName: stateName);
  }
}

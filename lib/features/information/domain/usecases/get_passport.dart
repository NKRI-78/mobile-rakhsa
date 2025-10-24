import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/features/information/data/models/passport.dart';

import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';

class GetPassportUseCase {
  final KbriRepository repository;

  GetPassportUseCase(this.repository);

  Future<Either<Failure, PassportContentModel>> execute({
    required String stateId,
  }) {
    return repository.infoPassport(stateId: stateId);
  }
}

import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class CheckRegisterStatusUseCase {
  final AuthRepository repository;

  CheckRegisterStatusUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String passport,
    required String noReg,
  }) {
    return repository.checkRegisterStatus(passport: passport, noReg: noReg);
  }
}

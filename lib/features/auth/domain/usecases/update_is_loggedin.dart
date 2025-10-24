import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class UpdateIsLoggedinUseCase {
  final AuthRepository repository;

  UpdateIsLoggedinUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String type,
    required String userId,
  }) {
    return repository.updateIsLoggedIn(type: type, userId: userId);
  }
}

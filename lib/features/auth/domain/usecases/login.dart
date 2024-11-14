import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthModel>> execute({
    required String value,
    required String password
  }) {
    return repository.login(
      value: value,
      password: password
    );
  }
}
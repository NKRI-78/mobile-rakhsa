import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String email,
    required String oldPassword,
    required String newPassword
  }) {
    return repository.forgotPassword(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword
    );
  }
}
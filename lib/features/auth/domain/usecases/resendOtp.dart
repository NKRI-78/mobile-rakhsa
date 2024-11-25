import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String email,
  }) {
    return repository.resendOtp(
      email: email,
    );
  }
}
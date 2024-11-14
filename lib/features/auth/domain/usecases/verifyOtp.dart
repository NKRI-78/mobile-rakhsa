import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String email,
    required String otp,
  }) {
    return repository.verifyOtp(
      email: email,
      otp: otp,
    );
  }
}
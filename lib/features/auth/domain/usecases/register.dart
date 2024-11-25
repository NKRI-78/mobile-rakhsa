import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthModel>> execute({
    required String fullname,
    required String email,
    required String phone,
    required String passport,
    required String emergencyContact,
    required String password
  }) {
    return repository.register(
      fullname: fullname,
      email: email,
      phone: phone,
      passport: passport,
      emergencyContact: emergencyContact,
      password: password,
    );
  }
}
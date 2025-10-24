import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class RegisterPassportUseCase {
  final AuthRepository repository;

  RegisterPassportUseCase(this.repository);

  Future<Either<Failure, PassportDataExtraction>> execute(String imagePath) {
    return repository.registerPassport(imagePath: imagePath);
  }
}

import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, void>> execute({required String avatar}) {
    return repository.updateProfile(avatar: avatar);
  }
}

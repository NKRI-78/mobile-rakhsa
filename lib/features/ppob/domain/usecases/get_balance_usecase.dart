import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class GetBalanceUseCase {
  final PPOBRepository repository;

  GetBalanceUseCase({required this.repository});

  Future<Either<Failure, int>> execute() async {
    return repository.getBalance();
  }
}
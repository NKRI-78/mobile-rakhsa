import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class GetDenomUseCase {
  final PPOBRepository repository;

  GetDenomUseCase({required this.repository});

  Future<Either<Failure, List<DenomTopupDataListEntity>>> execute() async {
    return repository.denomTopup();
  }
}
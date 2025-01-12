import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PayPlnPraUseCase {
  final PPOBRepository repository;

  PayPlnPraUseCase({required this.repository});

  Future<Either<Failure, void>> execute({
    required String idpel,
    required String nominal,
    required String ref2,
  }) async {
    return repository.payPraPLN(
      idpel: idpel,
      nominal: nominal,
      ref2: ref2,
    );
  }
}
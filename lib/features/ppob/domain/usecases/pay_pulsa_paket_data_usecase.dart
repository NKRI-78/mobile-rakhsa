import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PayPpobUseCase {
  final PPOBRepository repository;

  PayPpobUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String idpel,
    required String paymentChannel,
    required String paymentCode,
    required String productId,
    required String type
  }) async {
    return repository.payPpob(
      idpel: idpel,
      paymentChannel: paymentChannel,
      paymentCode: paymentCode,
      productId: productId,
      type: type 
    );
  }
}
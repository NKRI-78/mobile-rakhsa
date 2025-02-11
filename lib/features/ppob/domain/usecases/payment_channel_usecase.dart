import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PaymentChannelUseCase {
  final PPOBRepository repository;

  PaymentChannelUseCase(this.repository);

  Future<Either<Failure, List<PaymentData>>> execute() async {
    return repository.getPaymentChannel();
  }
}
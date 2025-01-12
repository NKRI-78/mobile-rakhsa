import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/entities/payment.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PaymentChannelUseCase {
  final PPOBRepository repository;

  PaymentChannelUseCase({required this.repository});

  Future<Either<Failure, List<PaymentDataEntity>>> execute() async {
    return repository.getPaymentChannel();
  }
}
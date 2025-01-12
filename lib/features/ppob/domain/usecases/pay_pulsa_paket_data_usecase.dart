import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PayPulsaAndPaketDataUseCase {
  final PPOBRepository repository;

  PayPulsaAndPaketDataUseCase({required this.repository});

  Future<Either<Failure, void>> execute({
    required String productCode,
    required String phone
  }) async {
    return repository.payPulsaAndPaketData(
      productCode: productCode,
      phone: phone
    );
  }
}
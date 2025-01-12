import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class InquiryTopupUseCase {
  final PPOBRepository repository;

  InquiryTopupUseCase({required this.repository});

  Future<Either<Failure, void>> execute({
    required String productId,
    required int productPrice,
    required String channel,
    required String topupby
  }) async {
    return repository.inquiryTopup(
      productId: productId,
      productPrice: productPrice,
      channel: channel,
      topupby: topupby
    );
  }
}
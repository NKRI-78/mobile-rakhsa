import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';

import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class InquiryPulsaUseCase {
  final PPOBRepository repository;

  InquiryPulsaUseCase(this.repository);

  Future<Either<Failure, List<PPOBPulsaInquiryData>>> execute({
    required String prefix,
    required String type
  }) async {
    return repository.inquiryPulsa(
      prefix: prefix,
      type: type
    );
  }
}
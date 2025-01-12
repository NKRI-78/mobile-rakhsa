import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/ppob/domain/entities/inquiry_pulsa.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class InquiryPulsaUseCase {
  final PPOBRepository repository;

  InquiryPulsaUseCase({required this.repository});

  Future<Either<Failure, List<PPOBPulsaInquiryDataEntity>>> execute({
    required String prefix,
    required String type
  }) async {
    return repository.inquiryPulsa(
      prefix: prefix,
      type: type
    );
  }
}
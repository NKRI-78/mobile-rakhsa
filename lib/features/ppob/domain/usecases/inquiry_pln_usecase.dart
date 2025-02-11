import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class InquiryPlnPraUseCase {
  final PPOBRepository repository;

  InquiryPlnPraUseCase(this.repository);

  Future<Either<Failure, PPOBTokenListrikInquiryDataEntity>> execute({
    required String idpel,
  }) async {
    return repository.inquiryPrabayarPLN(
      idpel: idpel,
    );
  }
}
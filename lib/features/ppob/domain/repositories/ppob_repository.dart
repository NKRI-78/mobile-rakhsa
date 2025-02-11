import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';
import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';
import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';
import 'package:rakhsa/features/ppob/domain/entities/payment.dart';

abstract class PPOBRepository {

  Future<Either<Failure, List<PPOBPulsaInquiryData>>> inquiryPulsa({
    required String prefix,
  });

  Future<Either<Failure, PPOBTokenListrikInquiryDataEntity>> inquiryPrabayarPLN({
    required String idpel
  });

  Future<Either<Failure, List<PaymentDataEntity>>> getPaymentChannel();

  Future<Either<Failure, int>> getBalance();

  Future<Either<Failure, void>> payPulsaAndPaketData({
    required String productCode,
    required String phone
  });

  Future<Either<Failure, void>> payPraPLN({
    required String idpel, 
    required String ref2,
    required String nominal
  });

  Future<Either<Failure, List<DenomTopupDataListEntity>>> denomTopup();

  Future<Either<Failure, void>> inquiryTopup({
    required String productId,
    required int productPrice,
    required String channel,
    required String topupby
  });
  
}
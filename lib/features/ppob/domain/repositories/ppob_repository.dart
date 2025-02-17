import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/data/models/inquiry_model.dart';
import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';
import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';
import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';

abstract interface class PPOBRepository {

  Future<Either<Failure, List<PPOBPulsaInquiryData>>> inquiryPulsa({
    required String prefix,
    required String type
  });

  Future<Either<Failure, PPOBTokenListrikInquiryDataEntity>> inquiryPrabayarPLN({
    required String idpel
  });

  Future<Either<Failure, List<PaymentData>>> getPaymentChannel();

  Future<Either<Failure, int>> getBalance();

  Future<Either<Failure, InquiryPayPpobModel>> payPpob({
    required String idpel, 
    required String paymentChannel, 
    required String paymentCode, 
    required String productId,
    required String type,
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
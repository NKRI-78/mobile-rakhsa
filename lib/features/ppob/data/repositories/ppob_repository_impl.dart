import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/ppob/data/datasources/ppob_remote_datasource.dart';
import 'package:rakhsa/features/ppob/data/models/inquiry_model.dart';
import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';
import 'package:rakhsa/features/ppob/domain/entities/denom_topup.dart';

import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';
import 'package:rakhsa/features/ppob/domain/repositories/ppob_repository.dart';

class PPOBRepositoryImpl implements PPOBRepository {
  final PPOBRemoteDataSourceImpl remoteDatasource;

  PPOBRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<PPOBPulsaInquiryData>>> inquiryPulsa({
    required String prefix,
    required String type
  }) async {
    try {
      var result = await remoteDatasource.inquiryPulsa(
        prefix: prefix,
        type: type 
      );
      return Right(result.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, PPOBTokenListrikInquiryDataEntity>> inquiryPrabayarPLN({required String idpel}) async {
    try {
      var result = await remoteDatasource.inquiryPrabayarPLN(idpel: idpel);
      return Right(result.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, List<PaymentData>>> getPaymentChannel() async {
    try {
      var result = await remoteDatasource.paymentChannelList();
      return Right(result.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override 
  Future<Either<Failure, int>> getBalance() async {
    try {
      var result = await remoteDatasource.getBalance();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, InquiryPayPpobModel>> payPpob({
    required String idpel, 
    required String paymentChannel, 
    required String paymentCode, 
    required String productId,
    required String type
  }) async {
    try {
      var result = await remoteDatasource.payPpob(
        idpel: idpel,
        paymentChannel: paymentChannel,
        paymentCode: paymentCode,
        productId: productId, 
        type: type,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, void>> payPraPLN({
    required String idpel, 
    required String ref2,
    required String nominal
  }) async {
    try {
      var result = await remoteDatasource.payPraPLN(
        idpel: idpel,
        ref2: ref2,
        nominal: nominal,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DenomTopupDataListEntity>>> denomTopup() async {
    try {
      var result = await remoteDatasource.denomTopup();
      return Right(result.body.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, void>> inquiryTopup({
    required String productId, 
    required int productPrice,
    required String channel,
    required String topupby
  }) async {
    try {
      var result = await remoteDatasource.inquiryTopup(
        productId: productId,
        productPrice: productPrice,
        channel: channel,
        topupby: topupby
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
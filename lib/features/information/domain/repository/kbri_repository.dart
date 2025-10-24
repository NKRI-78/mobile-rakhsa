import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/information/data/models/kbri.dart';
import 'package:rakhsa/features/information/data/models/passport.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';

abstract class KbriRepository {
  Future<Either<Failure, KbriInfoModel>> infoKbriStateId({
    required String stateId,
  });
  Future<Either<Failure, KbriInfoModel>> infoKbriStateName({
    required String stateName,
  });
  Future<Either<Failure, VisaContentModel>> infoVisa({required String stateId});
  Future<Either<Failure, PassportContentModel>> infoPassport({
    required String stateId,
  });
}

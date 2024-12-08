import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/information/data/models/kbri.dart';

abstract class KbriRepository {
  Future<Either<Failure, KbriInfoModel>> infoKbri({required String stateId});
}
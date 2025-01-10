import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/nearme/data/models/nearme.dart';

abstract class NearmeRepository {
  Future<Either<Failure, NearbyplaceModel>> getNearme({
    required double currentLat, 
    required double currentLng,
    required String type
  });
}
import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/nearme/data/models/nearme.dart';
import 'package:rakhsa/features/nearme/domain/repository/nearme_repository.dart';

class GetPlaceNearbyUseCase {
  final NearmeRepository repository;

  GetPlaceNearbyUseCase(this.repository);

  Future<Either<Failure, NearbyplaceModel>> execute({
    required double currentLat, 
    required double currentLng, 
    required String keyword, 
    required String type
  }) async {
    return repository.getNearme(
      currentLat: currentLat, 
      currentLng: currentLng, 
      keyword: keyword, 
      type: type
    );
  }
}
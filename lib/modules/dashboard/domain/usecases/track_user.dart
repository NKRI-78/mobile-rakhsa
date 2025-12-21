import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class TrackUserUseCase {
  final DashboardRepository repository;

  TrackUserUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String address,
    required double lat,
    required double lng,
  }) {
    return repository.userTrack(address: address, lat: lat, lng: lng);
  }
}

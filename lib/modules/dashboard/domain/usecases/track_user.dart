import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class TrackUserUseCase {
  final DashboardRepository repository;

  TrackUserUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required address,
    required lat,
    required lng,
  }) {
    return repository.userTrack(address: address, lat: lat, lng: lng);
  }
}

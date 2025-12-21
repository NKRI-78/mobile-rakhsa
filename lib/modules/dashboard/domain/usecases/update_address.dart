import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class UpdateAddressUseCase {
  final DashboardRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String address,
    required String state,
    required double lat,
    required double lng,
  }) {
    return repository.updateAddress(
      address: address,
      state: state,
      lat: lat,
      lng: lng,
    );
  }
}

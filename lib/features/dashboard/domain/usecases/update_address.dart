import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class UpdateAddressUseCase {
  final DashboardRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String address,
    required double lat,
    required double lng 
  }) {
    return repository.updateAddress(
      address: address,
      lat: lat,
      lng: lng
    );
  }
}
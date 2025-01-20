import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override 
  Future<Either<Failure, AuthModel>> login({
    required String value,
    required String password
  }) async {
    try {
      var result = await remoteDataSource.login(
        value: value,
        password: password
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, void>> updateIsLoggedIn({
    required String userId,
    required String type
  }) async {
    try {
      var result = await remoteDataSource.updateIsLoggedIn(
        userId: userId,
        type: type
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

 @override 
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      var result = await remoteDataSource.getProfile();
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, void>> updateProfile({required String avatar}) async {
    try {
      var result = await remoteDataSource.updateProfile(avatar: avatar);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthModel>> register({
    required String countryCode,
    required String passportNumber,
    required String fullName,
    required String nasionality,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String dateOfIssue,
    required String dateOfExpiry,
    required String registrationNumber,
    required String issuingAuthority,
    required String mrzCode,
    required String email,
    required String emergencyContact,
    required String password
  }) async {
    try {
      var result = await remoteDataSource.register(
        countryCode: countryCode,
        passportNumber: passportNumber,
        fullName: fullName,
        nasionality: nasionality,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        gender: gender,
        dateOfIssue: dateOfIssue,
        dateOfExpiry: dateOfExpiry,
        registrationNumber: registrationNumber,
        issuingAuthority: issuingAuthority,
        mrzCode: mrzCode,
        email: email,
        emergencyContact: emergencyContact,
        password: password
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthModel>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      var result = await remoteDataSource.verifyOtp(
        email: email,
        otp: otp,
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({
    required String email,
  }) async {
    try {
      var result = await remoteDataSource.resendOtp(
        email: email,
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email, 
    required String oldPassword, 
    required String newPassword
  }) async {
    try {
      var result = await remoteDataSource.forgotPassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}
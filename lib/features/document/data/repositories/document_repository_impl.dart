import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/document/data/datasource/document_remote_datasource.dart';
import 'package:rakhsa/features/document/domain/repository/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDatasource remoteDatasource;

  DocumentRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, void>> updateVisa({required String path}) async {
    try {
      final userId = StorageHelper.getUserId();
      if (userId != null) {
        await remoteDatasource.updateVisa(path: path, userId: userId);
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

   @override
  Future<Either<Failure, void>> deleteVisa() async {
    try {
      final userId = StorageHelper.getUserId();
      if (userId != null) {
        await remoteDatasource.deleteVisa(userId: userId);
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassport({required String path}) async {
    try {
      final userId = StorageHelper.getUserId();
      if (userId != null) {
        await remoteDatasource.updatePassport(path: path, userId: userId);
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  
 
}
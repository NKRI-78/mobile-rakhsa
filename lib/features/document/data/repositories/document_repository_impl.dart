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
      final session = await StorageHelper.getUserSession();
      await remoteDatasource.updateVisa(path: path, userId: session.user.id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVisa() async {
    try {
      final session = await StorageHelper.getUserSession();
      await remoteDatasource.deleteVisa(userId: session.user.id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassport({
    required String userId,
    required String path,
  }) async {
    try {
      await remoteDatasource.updatePassport(userId: userId, path: path);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}

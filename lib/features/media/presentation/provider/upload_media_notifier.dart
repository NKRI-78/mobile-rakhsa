
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/media/domain/entities/media.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

class UploadMediaNotifier extends ChangeNotifier {
  final UploadMediaUseCase useCase;

  UploadMediaNotifier({required this.useCase});

  Media? _entity;
  Media? get entity => _entity;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> send({
    required File file,
    required String folderName
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      file: file, 
      folderName: folderName
    );
    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
      debugPrint(l.message);
    }, (r) {
      _state = ProviderState.loaded;
      _entity = r;
    });
    notifyListeners();
  }
}
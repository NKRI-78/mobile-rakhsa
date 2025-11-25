import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/media/media_repository.dart';
import 'package:rakhsa/repositories/media/model/media.dart';

class SosProvider extends ChangeNotifier {
  final MediaRepository _repository;

  SosProvider(this._repository);

  Media? _sosVideo;
  Media? get sosVideo => _sosVideo;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;
  double get uploadPercent => _uploadProgress * 100;

  var _sendSosVideoState = RequestState.idle;
  bool isSendSosVideoState(List<RequestState> compareStates) =>
      compareStates.contains(_sendSosVideoState);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> sendSos(File file, {VoidCallback? onTimeout}) async {
    _sendSosVideoState = RequestState.loading;
    notifyListeners();

    try {
      final remoteSosVideo = await _repository.sendSosRecordVideo(
        video: file,
        onSendProgress: (count, total) {
          _uploadProgress = count / total;
          notifyListeners();
        },
      );

      _sosVideo = remoteSosVideo;
      _sendSosVideoState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      if (e.errorType == NetworkError.sendTimeout) {
        onTimeout?.call();
      }

      _errorMessage = e.message;
      _sendSosVideoState = RequestState.error;
      notifyListeners();
    }
  }
}

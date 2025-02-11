import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/event/domain/usecases/save_event.dart';

class SaveEventNotifier extends ChangeNotifier {
  final SaveEventUseCase useCase;

  SaveEventNotifier({required this.useCase});

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> save(BuildContext context, {
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId,
    required String description
  }) async {
    _state = ProviderState.loading;
    Future.delayed(Duration.zero, () => notifyListeners());

    final result = await useCase.execute(
      title: title,
      startDate: startDate,
      endDate: endDate,
      continentId: continentId,
      stateId: stateId,
      description: description
    );
    result.fold((l) {
      _state = ProviderState.error;
      Future.delayed(Duration.zero, () => notifyListeners());
      _message = l.message;

      ShowSnackbar.snackbarErr('Gagal membuat agenda [${l.message}]');
    }, (r) async {
      _state = ProviderState.loaded;
      Future.delayed(Duration.zero, () => notifyListeners());

      Navigator.of(context).pop();
      ShowSnackbar.snackbarOk('Berhasil membuat agenda');
    });
  }
}
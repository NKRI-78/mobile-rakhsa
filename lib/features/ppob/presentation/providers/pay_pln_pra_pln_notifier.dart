import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/usecases/pay_pln_pra_usecase.dart';

class PayPlnPraProvider with ChangeNotifier {
  final PayPlnPraUseCase useCase;

  PayPlnPraProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> pay({
    required String idpel,
    required String ref2,
    required String nominal
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      idpel: idpel,
      ref2: ref2,
      nominal: nominal,
    );

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
      debugPrint(message.toString());
    }, (r) {
      _state = ProviderState.loaded;
    });

    notifyListeners();
  }

}
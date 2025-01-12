import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/usecases/pay_pulsa_paket_data_usecase.dart';

class PayPulsaAndPaketDataProvider with ChangeNotifier {
  final PayPulsaAndPaketDataUseCase useCase;

  PayPulsaAndPaketDataProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> pay({
    required String productCode,
    required String phone
  }) async {

    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      productCode: productCode,
      phone: phone
    );

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {
      _state = ProviderState.loaded;
    });
    notifyListeners();
  }

}
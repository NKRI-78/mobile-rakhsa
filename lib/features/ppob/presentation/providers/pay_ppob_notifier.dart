import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/usecases/pay_ppob_usecase.dart';

class PayPpobNotifier with ChangeNotifier {
  final PayPpobUseCase useCase;

  PayPpobNotifier({
    required this.useCase
  });

  String paymentAccess = "";
  String paymentType = "";
  String orderId = "";

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> pay({
    required String idpel,
    required String productId,
    required String paymentChannel,
    required String paymentCode,
    required String type 
  }) async {

    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      productId: productId,
      idpel: idpel,
      paymentChannel: paymentChannel,
      paymentCode: paymentCode,
      type: type 
    );

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {
      paymentAccess = r.data.paymentAccess;
      paymentType = r.data.paymentType;
      orderId = r.data.orderId;

      _state = ProviderState.loaded;
    });
    notifyListeners();
  }

}
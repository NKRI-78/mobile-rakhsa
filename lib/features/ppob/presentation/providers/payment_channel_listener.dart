import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/ppob/data/models/payment_model.dart';

import 'package:rakhsa/features/ppob/domain/usecases/payment_channel_usecase.dart';

class PaymentChannelProvider with ChangeNotifier {
  final PaymentChannelUseCase useCase;

  PaymentChannelProvider({
    required this.useCase
  });

  String paymentChannel = "-";
  String paymentCode = "-";
  String paymentName = "-";

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  List<PaymentData> _entity = [];
  List<PaymentData> get entity => [..._entity];

  void reset() {
    paymentChannel = "";
    paymentCode = "";
    paymentName = "";
  }

  void selectPaymentChannel({required PaymentData paymentData}) {
    paymentChannel = paymentData.id.toString();
    paymentCode = paymentData.nameCode;
    paymentName = paymentData.name;
    
    notifyListeners();
  }

  Future<void> fetch() async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute();

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {

      _entity = [];
      _entity.addAll(r);
      _state = ProviderState.loaded;

      if(entity.isEmpty) {
        _message = "No data found";
        _state = ProviderState.empty;
      }
    });

    notifyListeners();
  }

}
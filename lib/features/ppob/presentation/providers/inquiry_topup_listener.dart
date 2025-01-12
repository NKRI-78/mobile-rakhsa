import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/usecases/inquiry_topup_usecase.dart';

class InquiryTopupProvider with ChangeNotifier {
  final InquiryTopupUseCase useCase;

  InquiryTopupProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> inquiryTopup({
    required String productId, 
    required int productPrice,
    required String channel,
    required String topupby
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      productId: productId,
      productPrice: productPrice,
      channel: channel,
      topupby: topupby
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
import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/entities/inquiry_tokenlistrik.dart';
import 'package:rakhsa/features/ppob/domain/usecases/inquiry_pln_usecase.dart';

class InquiryPlnPraProvider with ChangeNotifier {
  final InquiryPlnPraUseCase useCase;

  InquiryPlnPraProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  PPOBTokenListrikInquiryDataEntity entity = PPOBTokenListrikInquiryDataEntity();

  Future<void> fetch({required String idpel}) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(idpel: idpel);
    
    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {

      entity = r;
      _state = ProviderState.loaded;
    });

    notifyListeners();
  }

}
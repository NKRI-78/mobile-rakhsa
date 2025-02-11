import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';

import 'package:rakhsa/features/ppob/domain/usecases/inquiry_pulsa_usecase.dart';

class InquiryPulsaProvider with ChangeNotifier {
  final InquiryPulsaUseCase useCase;

  InquiryPulsaProvider({
    required this.useCase
  });

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  List<PPOBPulsaInquiryData> _entity = [];
  List<PPOBPulsaInquiryData> get entity => [..._entity];

  void reset() {
    _entity = [];

    _state = ProviderState.empty;
    notifyListeners();
  }

  Future<void> fetch({required String prefix, required String type}) async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      prefix: prefix,
    );

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
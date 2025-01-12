import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/usecases/get_balance_usecase.dart';

class GetBalanceProvider with ChangeNotifier {
  final GetBalanceUseCase useCase;

  GetBalanceProvider({
    required this.useCase
  });

  int balance = 0;

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> fetch() async {

    final result = await useCase.execute();

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {

      balance = r;
      _state = ProviderState.loaded;
    });

    notifyListeners();
  }

}
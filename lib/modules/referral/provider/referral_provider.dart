import 'package:flutter/foundation.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';
import 'package:rakhsa/repositories/referral/referral_repository.dart';
import 'package:rakhsa/service/storage/storage.dart';

import 'referral_state.dart';
export 'referral_state.dart';

class ReferralProvider extends ChangeNotifier {
  final ReferralRepository _repository;
  ReferralProvider(this._repository);

  var _state = ReferralState();
  ReferralState get state => _state;

  bool get hasReferralCode => _repository.hasReferralCode();

  bool roamingIsActive([ReferralPackage? package]) {
    if (package == null) return false;
    return DateTime.now().isBefore(package.endAt);
  }

  Future<void> activateReferralCode(
    String uid, {
    Duration delay = Duration.zero,
  }) async {
    setState(_state.copyWith(state: RequestState.loading));

    if (hasReferralCode) {
      try {
        await Future.delayed(delay);
        final newReferralData = await _repository.activateReferralCode(uid);
        setState(
          _state.copyWith(data: newReferralData, state: RequestState.success),
        );
      } on NetworkException catch (e) {
        setState(
          _state.copyWith(
            state: RequestState.error,
            error: ErrorState(
              title: e.title,
              message: e.message,
              errorCode: e.errorCode,
              source: ErrorSource.network,
            ),
          ),
        );
        await StorageHelper.removeUserSession();
      } on ReferralException catch (e) {
        setState(
          _state.copyWith(
            state: RequestState.error,
            error: ErrorState(
              title: e.title,
              message: e.message,
              errorCode: e.errorCode,
              source: ErrorSource.referral,
            ),
          ),
        );
        await StorageHelper.removeUserSession();
      }
    }
  }

  void setState(ReferralState newState) {
    _state = newState;
    notifyListeners();
  }
}

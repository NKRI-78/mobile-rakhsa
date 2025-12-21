// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:rakhsa/core/client/errors/errors.dart';

import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';

class ReferralState extends Equatable {
  final RequestState state;
  final ReferralData? data;
  final ErrorState? error;

  const ReferralState({this.state = RequestState.idle, this.data, this.error});

  bool get isLoading => state == RequestState.loading;
  bool get isSuccess => state == RequestState.success;
  bool get isError => state == RequestState.error;

  @override
  List<Object?> get props => [state, data, error];

  ReferralState copyWith({
    RequestState? state,
    ReferralData? data,
    ErrorState? error,
  }) {
    return ReferralState(
      state: state ?? this.state,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

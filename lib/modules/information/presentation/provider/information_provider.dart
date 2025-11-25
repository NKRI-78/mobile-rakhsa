import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/information/information_repository.dart';
import 'package:rakhsa/repositories/information/model/geo_node.dart';
import 'package:rakhsa/repositories/information/model/kbri.dart';

class InformationProvider extends ChangeNotifier {
  final InformationRepository _repository;

  InformationProvider({required InformationRepository repository})
    : _repository = repository;

  // data state

  var _countries = <GeoNode>[];
  List<GeoNode> get countries => _countries;

  KBRI? _currentKbri;
  KBRI? get currentKbri => _currentKbri;

  KBRI? _kbriCountry;
  KBRI? get kbriCountry => _kbriCountry;

  String? _passportData;
  String? get passportData => _passportData;

  String? _visaData;
  String? get visaData => _visaData;

  // condition state

  var _fetchCountryState = RequestState.idle;
  bool isFetchCountryState(RequestState state) => _fetchCountryState == state;

  var _getCurrentKbriState = RequestState.idle;
  bool isGetCurrentKbriState(RequestState state) =>
      _getCurrentKbriState == state;

  var _getKbriByCountryIdState = RequestState.idle;
  bool isGetKbriByCountryIdState(RequestState state) =>
      _getKbriByCountryIdState == state;

  var _getPassportState = RequestState.idle;
  bool isGetPassportState(RequestState state) => _getPassportState == state;

  var _getVisaState = RequestState.idle;
  bool isGetVisaState(RequestState state) => _getVisaState == state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // event

  Future<void> fetchCountry(String q) async {
    _fetchCountryState = RequestState.loading;
    notifyListeners();

    try {
      final remoteCountries = await _repository.getCountries(q);

      _countries = remoteCountries;
      _fetchCountryState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _fetchCountryState = RequestState.error;
      notifyListeners();
    }
  }

  void clearCountry() => _countries.clear();

  Future<void> getCurrentKBRI(String country) async {
    _getCurrentKbriState = RequestState.loading;
    notifyListeners();

    try {
      final remoteKbri = await _repository.getKBRIByCurrentCountry(country);

      _currentKbri = remoteKbri;
      _getCurrentKbriState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getCurrentKbriState = RequestState.error;
      notifyListeners();
    }
  }

  Future<void> getKBRIByCountryId(String id) async {
    _getKbriByCountryIdState = RequestState.loading;
    notifyListeners();

    try {
      final remoteKbri = await _repository.getKBRIByCountryId(id);

      _kbriCountry = remoteKbri;
      _getKbriByCountryIdState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getKbriByCountryIdState = RequestState.error;
      notifyListeners();
    }
  }

  Future<void> getPassportInfo(String stateId) async {
    _getPassportState = RequestState.loading;
    notifyListeners();

    try {
      final remotePassport = await _repository.getPassportInfo(stateId);
      _passportData = remotePassport;
      _getPassportState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getPassportState = RequestState.error;
      notifyListeners();
    }
  }

  Future<void> getVisaInfo(String stateId) async {
    _getVisaState = RequestState.loading;
    notifyListeners();

    try {
      final remoteVisa = await _repository.getVisaInfo(stateId);
      _visaData = remoteVisa;
      _getVisaState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getVisaState = RequestState.error;
      notifyListeners();
    }
  }
}

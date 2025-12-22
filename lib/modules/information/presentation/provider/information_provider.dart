import 'package:flutter/material.dart';
import 'package:rakhsa/core/client/errors/exceptions/exceptions.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/information/information_repository.dart';
import 'package:rakhsa/repositories/information/model/geo_node.dart';
import 'package:rakhsa/repositories/information/model/kbri.dart';

class InformationProvider extends ChangeNotifier {
  final InformationRepository _repository;

  InformationProvider({required InformationRepository repository})
    : _repository = repository;

  var _countries = <GeoNode>[];
  List<GeoNode> get countries => _countries;

  KBRI? _currentKbri;
  KBRI? get currentKbri => _currentKbri;

  KBRI? _kbriCountry;
  KBRI? get kbriCountry => _kbriCountry;

  var _fetchCountryState = RequestState.idle;
  bool isFetchCountry(RequestState state) => _fetchCountryState == state;

  var _getCurrentKbriState = RequestState.idle;
  bool isGetCurrentKbri(RequestState state) => _getCurrentKbriState == state;

  var _getKbriByCountryIdState = RequestState.idle;
  bool isGetKbriByCountryId(RequestState state) =>
      _getKbriByCountryIdState == state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCountry(String q) async {
    _fetchCountryState = .loading;
    notifyListeners();

    try {
      final remoteCountries = await _repository.getCountries(q);

      _countries = remoteCountries;
      _fetchCountryState = .success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _fetchCountryState = .error;
      notifyListeners();
    }
  }

  void clearCountry() => _countries.clear();

  Future<void> getCurrentKBRI(String country) async {
    _getCurrentKbriState = .loading;
    notifyListeners();

    try {
      final remoteKbri = await _repository.getKBRIByCurrentCountry(country);

      _currentKbri = remoteKbri;
      _getCurrentKbriState = .success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getCurrentKbriState = .error;
      notifyListeners();
    }
  }

  Future<void> getKBRIByCountryId(String id) async {
    _getKbriByCountryIdState = .loading;
    notifyListeners();

    try {
      final remoteKbri = await _repository.getKBRIByCountryId(id);

      _kbriCountry = remoteKbri;
      _getKbriByCountryIdState = .success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _getKbriByCountryIdState = .error;
      notifyListeners();
    }
  }
}

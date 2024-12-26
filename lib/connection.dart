import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionHelper {
  static final Connectivity _connectivity = Connectivity();

  // Check if the internet is connected
  static Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
  }

  // Listen for connectivity changes
  static StreamSubscription<ConnectivityResult> listenToConnectionChanges(Function(ConnectivityResult) onChange) {
    return _connectivity.onConnectivityChanged.listen(onChange);
  }
}
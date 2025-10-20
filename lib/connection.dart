import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionHelper {
  static final Connectivity connectivity = Connectivity();

  // Check if the internet is connected
  static Future<bool> isConnected() async {
    var connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  // Listen for connectivity changes
  static StreamSubscription<List<ConnectivityResult>> listenToConnectionChanges(
    Function(List<ConnectivityResult>)? onChange,
  ) => connectivity.onConnectivityChanged.listen(onChange);
}

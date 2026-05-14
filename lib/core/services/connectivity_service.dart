import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Streams a coarse online/offline boolean. Treats any non-`none` result as
/// online — repositories can still hit network errors and react accordingly.
class ConnectivityService {
  ConnectivityService(this._connectivity);
  final Connectivity _connectivity;

  Stream<bool> onStatusChange() => _connectivity
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors device connectivity state and exposes a stream.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Current connectivity status
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream of connectivity changes (emits true when connected)
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}

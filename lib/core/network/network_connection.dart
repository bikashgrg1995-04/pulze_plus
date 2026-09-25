import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnection {
  NetworkConnection({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();

    return result.any((connection) => connection != ConnectivityResult.none);
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectivityStatus { connected, disconnected, unknown }

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

class ConnectivityService {
  final InternetConnectionChecker _checker = InternetConnectionChecker.createInstance(
    addresses: [
      AddressCheckOption(uri: Uri.parse('https://jsonplaceholder.typicode.com/albums/1')),
      AddressCheckOption(uri: Uri.parse('https://www.google.com')),
      AddressCheckOption(uri: Uri.parse('https://www.cloudflare.com')),
    ],
  );
  ConnectivityStatus _lastStatus = ConnectivityStatus.unknown;

  ConnectivityStatus get lastStatus => _lastStatus;

  Stream<ConnectivityStatus> get statusStream {
    return _checker.onStatusChange.map((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          return ConnectivityStatus.connected;
        case InternetConnectionStatus.disconnected:
          return ConnectivityStatus.disconnected;
        case InternetConnectionStatus.slow:
          return ConnectivityStatus.connected;
      }
    });
  }

  Future<bool> get isConnected async {
    try {
      return await _checker.hasConnection;
    } catch (_) {
      return true;
    }
  }

  Future<bool> checkConnection() async {
    final connected = await isConnected;
    _lastStatus = connected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected;
    return connected;
  }
}

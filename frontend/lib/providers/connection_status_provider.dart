import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionStatusProvider = StreamProvider<bool>((ref) {
  return _connectionStream();
});

Stream<bool> _connectionStream() async* {
  while (true) {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      yield result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      yield false;
    }
    await Future.delayed(const Duration(seconds: 10));
  }
}

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

const _probeTimeout = Duration(seconds: 3);
const _pollInterval = Duration(seconds: 25);

Future<bool> _probe(List<ConnectivityResult> transports) async {
  if (transports.every((result) => result == ConnectivityResult.none)) {
    return false;
  }
  final client = HttpClient()..connectionTimeout = _probeTimeout;
  try {
    final request = await client
        .getUrl(Uri.https('www.gstatic.com', '/generate_204'))
        .timeout(_probeTimeout);
    request.followRedirects = false;
    final response = await request.close().timeout(_probeTimeout);
    return response.statusCode == HttpStatus.noContent;
  } on IOException {
    return false;
  } on TimeoutException {
    return false;
  } finally {
    client.close(force: true);
  }
}

Stream<bool> observeReachability() {
  final connectivity = Connectivity();
  return Stream<void>.multi((controller) {
        final subscription = connectivity.onConnectivityChanged.listen(
          (_) => controller.add(null),
          onError: controller.addError,
        );
        final timer = Timer.periodic(
          _pollInterval,
          (_) => controller.add(null),
        );
        controller.add(null);
        controller.onCancel = () {
          timer.cancel();
          return subscription.cancel();
        };
      })
      .asyncMap((_) async => _probe(await connectivity.checkConnectivity()))
      .distinct();
}

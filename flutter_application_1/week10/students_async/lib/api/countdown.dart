import 'package:flutter/foundation.dart';

/// Counts from [from] down to 0, one value per second.
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
    // After the yield: if you still see ticks after leaving the screen,
    // somebody forgot to cancel the subscription.
    debugPrint('tick $i');
  }
}

import 'session.dart';

/// R9: sealed class, rendered by an exhaustive switch.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(Session session, DateTime now) {
    final diff = session.starts.difference(now);
    if (diff > Duration.zero) {
      return Upcoming(diff);
    }
    final since = -diff;
    if (since < Session.length) {
      return Started(since);
    }
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.since);
  final Duration since;
}

final class Ended extends Countdown {
  const Ended();
}

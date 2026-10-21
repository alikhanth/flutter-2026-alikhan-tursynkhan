sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  final Duration duration;
  const Upcoming(this.duration);
}

class Started extends Countdown {
  final Duration duration;
  const Started(this.duration);
}

class Ended extends Countdown {
  const Ended();
}

Countdown getCountdown(DateTime starts) {
  final now = DateTime.now();
  final diff = starts.difference(now);

  if (diff.isNegative) {
    // Assuming events last roughly 2 hours for display logic
    if (diff.inHours.abs() < 2) return Started(diff.abs());
    return const Ended();
  }
  return Upcoming(diff);
}

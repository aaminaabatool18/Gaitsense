
class MonitoringSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int movementEventCount;
  final bool isSimulated;

  const MonitoringSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.movementEventCount,
    required this.isSimulated,
  });

  Duration get duration {
    return endTime.difference(startTime);
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m ${seconds}s';
  }
}

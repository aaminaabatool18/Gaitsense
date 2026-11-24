
import '../models/monitoring_session.dart';

class MonitoringService {
  final List<MonitoringSession> _sessions = [];

  MonitoringService() {
    _generateSimulatedSessions();
  }

  void _generateSimulatedSessions() {
    final now = DateTime.now();

    final durations = [25, 18, 32, 15, 28, 22, 35];
    final eventCounts = [3, 1, 4, 0, 2, 3, 5];

    for (int i = 0; i < 7; i++) {
      final endTime = now.subtract(
        Duration(days: i, hours: 1),
      );

      final startTime = endTime.subtract(
        Duration(minutes: durations[i]),
      );

      _sessions.add(
        MonitoringSession(
          id: 'demo_${i + 1}',
          startTime: startTime,
          endTime: endTime,
          movementEventCount: eventCounts[i],
          isSimulated: true,
        ),
      );
    }
  }

  List<MonitoringSession> getSessions() {
    return List.unmodifiable(_sessions);
  }

  int get totalSessions {
    return _sessions.length;
  }

  int get totalMovementEvents {
    return _sessions.fold<int>(
      0,
      (total, session) =>
          total + session.movementEventCount,
    );
  }

  Duration get totalMonitoringDuration {
    return _sessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  List<MonitoringSession> getRecentSessions({
    int limit = 3,
  }) {
    return _sessions.take(limit).toList();
  }
}

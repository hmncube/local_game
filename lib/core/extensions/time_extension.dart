extension TimeFormatter on int {
  String toTimeString() {
    final int totalSeconds = this;

    if (totalSeconds < 60) {
      return '$totalSeconds seconds';
    }

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final buffer = StringBuffer();

    if (hours > 0) {
      buffer.write('$hours ${hours == 1 ? 'hour' : 'hours'} ');
    }
    if (minutes > 0) {
      buffer.write('$minutes ${minutes == 1 ? 'minute' : 'minutes'} ');
    }
    if (seconds > 0) {
      buffer.write('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }

    return buffer.toString().trim();
  }
}

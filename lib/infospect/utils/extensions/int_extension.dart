import 'package:inspector/infospect/utils/extensions/double_extension.dart';

extension IntExtension on int {
  String get toReadableTime {
    if (this < 0) {
      return "-1 ms";
    }
    if (this <= 1000) {
      return "$this ms";
    }
    if (this <= 60000) {
      return "${(this / 1000).formattedString} s";
    }

    final Duration duration = Duration(milliseconds: this);

    return "${duration.inMinutes} min ${duration.inSeconds.remainder(60)} s "
        "${duration.inMilliseconds.remainder(1000)} ms";
  }

  String get toReadableBytes {
    if (this < 0) {
      return "-1 B";
    }
    if (this <= 1000) {
      return "$this B";
    }
    if (this <= 1000000) {
      return "${(this / 1000).formattedString} kB";
    }

    return "${(this / 1000000).formattedString} MB";
  }

  String get formatTimeUnit {
    return (this < 10) ? "0$this" : "$this";
  }
}

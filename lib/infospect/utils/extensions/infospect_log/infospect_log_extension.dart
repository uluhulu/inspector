import 'package:inspector/infospect/features/logger/models/infospect_log.dart';

extension InfospectLogExtension on InfospectLog {
  String get sharableData {
    String data = 'Level: ${level.name}\n'
        '$timestamp: $message\n';
    if (error != null) {
      data += 'Error: $error\n';
    }
    if (stackTrace != null) {
      data += 'Stack Trace: $stackTrace\n';
    }
    return data;
  }
}

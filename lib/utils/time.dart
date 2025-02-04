import 'package:intl/intl.dart';

String getTimeInLocalZone(DateTime time) {
  DateTime localTime = time.toLocal();
  var formatter = DateFormat('h:mm a');
  return formatter.format(localTime);
}
import 'dart:async';
import 'dart:convert';
import 'package:splitemate/service/ws/ws_service.dart';

class MessageStreamService {
  final WebSocketService webSocketService;

  MessageStreamService(this.webSocketService);

  Stream<Map<String, dynamic>> get transactionStream => webSocketService.stream
      .map((message) => json.decode(message) as Map<String, dynamic>)
      .where((message) => message.containsKey('message'))
      .map((message) => message['message'] as Map<String, dynamic>)
      .where((nestedMessage) => nestedMessage['type'] == 'transaction_message');

  Stream get recentUpdatesStream => webSocketService.stream
      .map((raw) => json.decode(raw))
      .where((message) => message['type'] == 'recentUpdate');
}

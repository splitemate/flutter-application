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

  Stream<Map<String, dynamic>> get activityStream => webSocketService.stream
      .map((raw) => json.decode(raw) as Map<String, dynamic>)
      .where((message) => message.containsKey('message'))
      .map((message) => message['message'] as Map<String, dynamic>)
      .where((nestedMessage) =>
          nestedMessage.containsKey('data') &&
          nestedMessage['data'].containsKey('activity'))
      .map((nestedMessage) =>
          nestedMessage['data']['activity'] as Map<String, dynamic>);
}

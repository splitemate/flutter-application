abstract class IWebSocketService {
  Future<void> connect(String url, Map<String, String> headers);
  Stream<String> get stream;
  Future<void> disconnect();
  Future<void> sendMessage(String message);
}

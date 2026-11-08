/// All Socket.io event name constants for the chat gateway.
/// Both client-emitted and server-emitted events are defined here.
class ChatSocketEvents {
  ChatSocketEvents._();

  /// Emitted by the server upon successful JWT authentication.
  static const String connectionSuccess = 'connection_success';

  /// Emitted by the server when authentication fails.
  static const String connectionError = 'connection_error';

  /// Response to [joinChat] — carries paginated message history.
  static const String chatHistory = 'chatHistory';

  /// Delivered to the sender's personal room after [sendMessage].
  static const String newMessage = 'newMessage';

  /// Broadcast to the chat room for every new message (lightweight).
  static const String messageReceived = 'messageReceived';

  /// Broadcast to the chat room when a participant marks a message as read.
  static const String messageRead = 'messageRead';

  /// Broadcast to others in the chat room while someone is typing.
  static const String typingResponse = 'typingResponse';

  /// Broadcast to others in the chat room when typing stops.
  static const String stopTypingResponse = 'stopTypingResponse';

  /// Global gateway error event — safe errors only.
  static const String chatError = 'chat_error';

  /// Join a chat room and request message history.
  static const String joinChat = 'joinChat';

  /// Send a new message (creates the chat automatically if needed).
  static const String sendMessage = 'sendMessage';

  /// Mark a specific message as read.
  static const String markRead = 'markRead';

  /// Notify others that the current user is typing.
  static const String typing = 'typing';

  /// Notify others that the current user stopped typing.
  static const String stopTyping = 'stopTyping';
}

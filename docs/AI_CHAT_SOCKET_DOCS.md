# AI Chat WebSocket Documentation

Documentation for connecting to and interacting with the AI Chatbot over WebSockets (`Socket.IO`).

---

## 1. Connection Details

- **Protocol:** WebSocket (`Socket.IO`)
- **Namespace:** `/ai-chat`
- **Base URL:** `https://nodmac.com/ai-chat` (Production) / `ws://<HOST>:<PORT>/ai-chat` (Local)
- **Transports:** `['websocket']`

---

## 2. Authentication

Connection requires a valid JWT access token passed via `auth`, `query`, or `headers`.

### Example (Auth Object):
```json
{
  "auth": {
    "token": "Bearer <JWT_ACCESS_TOKEN>"
  }
}
```

---

## 3. Events Summary

### 📤 Client $\rightarrow$ Server (Emit)

| Event | Payload | Description |
| :--- | :--- | :--- |
| `aiChat` | `{"message": "Your question here"}` | Sends a prompt/question to the AI |

---

### 📥 Server $\rightarrow$ Client (Listen)

| Event | Payload Example | Description |
| :--- | :--- | :--- |
| `connection_success` | `{"success": true, "userId": 1, "namespace": "/ai-chat"}` | Connection & authentication successful |
| `aiChatStatus` | `{"success": true, "status": "processing", "message": "AI is processing your message."}` | Sent immediately when AI begins processing |
| `aiChatResponse` | `{"success": true, "data": {"thread_id": "80", "response": "..."}}` | Final AI generated answer |
| `aiChatError` | `{"success": false, "code": "AI_LIMIT_REACHED", "message": "..."}` | Error during chat processing |
| `connection_error` | `{"success": false, "code": "AUTH_INVALID", "message": "..."}` | Auth failure or missing token |

---

## 4. Error Codes

| Error Code | Description |
| :--- | :--- |
| `AUTH_REQUIRED` | No token provided in connection handshake. |
| `AUTH_INVALID` | Token expired or invalid JWT payload. |
| `VALIDATION_ERROR` | `message` field is missing or empty. |
| `SUBSCRIPTION_REQUIRED` | User does not have an active premium subscription. |
| `FEATURE_NOT_INCLUDED` | User's active plan does not include AI Chat feature. |
| `AI_LIMIT_REACHED` | Monthly AI query limit reached for the user. |
| `AI_SERVICE_ERROR` | Python AI upstream service is unavailable. |
| `INTERNAL_ERROR` | Server internal error. |

---

## 5. How to Use in Flutter

### Step 1: Add Dependency (`pubspec.yaml`)
```yaml
dependencies:
  socket_io_client: ^3.0.2
```

---

### Step 2: Connect to Socket
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io(
  'https://nodmac.com/ai-chat',
  IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': 'Bearer $jwtAccessToken'})
      .build(),
);
```

---

### Step 3: Listen for Events
```dart
// 1. Connection Success
socket.on('connection_success', (data) {
  print('Connected successfully: $data');
});

// 2. AI Processing Status (Show loading indicator)
socket.on('aiChatStatus', (data) {
  print(data['message']); // "AI is processing your message."
});

// 3. AI Response (Display answer in UI)
socket.on('aiChatResponse', (data) {
  String answer = data['data']['response'];
  String threadId = data['data']['thread_id'];
  print('AI: $answer');
});

// 4. Error Handling
socket.on('aiChatError', (data) {
  print('AI Error [${data['code']}]: ${data['message']}');
});

// 5. Connection Error
socket.on('connection_error', (data) {
  print('Auth Error: ${data['message']}');
});
```

---

### Step 4: Send Message
```dart
void sendAiMessage(String message) {
  socket.emit('aiChat', {
    'message': message,
  });
}
```

---

### Step 5: Disconnect on Exit
```dart
@override
void dispose() {
  socket.disconnect();
  socket.dispose();
  super.dispose();
}
```

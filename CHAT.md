#  Chat — Implementation Guide

This document describes the full architecture of the **real-time chat system** built for both the **Faculty** and **Student** flows of the msollaally campus app.

---

## Table of Contents

1. [Overview](#overview)
2. [Backend API Reference](#backend-api-reference)
3. [Socket.IO Event Reference](#socketio-event-reference)
4. [Faculty Chat (Core)](#faculty-chat-core)
5. [Student Campus Chat](#student-campus-chat)
6. [Shared Concepts](#shared-concepts)
7. [Key Bugs Fixed](#key-bugs-fixed)
8. [Architecture Decisions](#architecture-decisions)

---

## Overview

Both flows share a **single backend** at `https://api.nodmac.com/chat`. The student implementation mirrors the faculty implementation but lives in a separate module under `feature/student/campus/` so that each role can evolve independently.

```
lib/
├── core/chat/                          ← Faculty chat (shared/core layer)
│   ├── config/chat_socket_events.dart
│   ├── controller/chat_controller.dart
│   ├── model/chat_message_model.dart
│   ├── screen/chat_screen.dart
│   └── service/chat_socket_service.dart
│
└── feature/student/campus/
    ├── campus_inbox/                   ← Student inbox list
    │   ├── controller/chat_controller.dart (InboxController)
    │   ├── screen/inbox_screen.dart
    │   └── widgets/
    │       ├── inbox_chat_tile.dart
    │       └── inbox_filter_tabs.dart
    │
    └── chat/                           ← Student chat room
        ├── config/student_chat_socket_events.dart
        ├── controller/student_campus_chat_controller.dart
        ├── model/
        │   ├── student_chat_message_model.dart
        │   └── student_chat_room_model.dart
        ├── repository/student_chat_repository.dart
        ├── screen/chat_screen.dart (CampusChatScreen)
        ├── service/
        │   ├── student_chat_api_service.dart
        │   └── student_chat_socket_service.dart
        └── widgets/
            ├── chat_app_bar.dart
            ├── chat_input_field.dart
            └── chat_message_bubble.dart
```

---

## Backend API Reference

Base URL: `https://api.nodmac.com/chat`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/chat` | List all chat rooms for the current user |
| `GET` | `/chat/:id` | Get a single chat room with participants |
| `POST` | `/chat` | Create a new chat room |
| `GET` | `/chat/:id/messages` | Paginated message history (`?page=1&limit=20`) |
| `POST` | `/chat/messages` | Send a message via REST (backup path) |

All requests use `Bearer` JWT token authentication via the `Authorization` header.

---

## Socket.IO Event Reference

Connection URL: `https://api.nodmac.com/chat` with `websocket` transport.

### Server → Client

| Event | Payload | Description |
|-------|---------|-------------|
| `connection_success` | `{ success, userId }` | Fired on successful socket auth |
| `connection_error` | `{ message }` | Auth failure |
| `chatHistory` | `{ total, page, limit, data: Message[] }` | Response to `joinChat` |
| `newMessage` | `Message` | Delivered to the sender only |
| `messageReceived` | `Message` | Broadcast to the chat room |
| `messageRead` | `{ messageId, userId }` | Read receipt broadcast |
| `typingResponse` | `{ chatId, userId }` | Someone started typing |
| `stopTyping` | `{ chatId, userId }` | Someone stopped typing |
| `chat_error` | `{ message }` | Safe gateway error |

### Client → Server

| Event | Payload | Description |
|-------|---------|-------------|
| `joinChat` | `{ chatId, page, limit }` | Join a room and fetch history |
| `sendMessage` | `{ receiverIds, content, type, chatName? }` | Send a message |
| `markRead` | `{ messageId, chatId }` | Mark message as read |
| `typing` | `{ chatId }` | Notify typing started |
| `stopTyping` | `{ chatId }` | Notify typing stopped |

> **Important:** `receiverIds` is always required by the backend for `sendMessage`, even for existing chats. We backfill it from `currentRoom.participants` after loading the room.

---

## Faculty Chat (Core)

**Location:** `lib/core/chat/`

The faculty chat is the **original production implementation**. It serves as the reference architecture that the student chat mirrors.

### Key Files

#### `chat_socket_events.dart`
A fully documented constants class for all Socket.IO event names. Both emitted and received events are named, grouped, and documented with dartdoc comments.

#### `chat_controller.dart` (`ChatController extends GetxController`)
Manages the full chat room lifecycle:
- Reactive state: `messages`, `isLoading`, `typingUserIds`, `errorMessage`, `currentRoom`, `userId`
- Owns a `TextEditingController` (disposed in `onClose`)
- `initialize(Map args)` — idempotent entry point guarded by `_isInitializing` flag and a chat-key check to avoid re-initialization on hot reload
- Connects socket → resolves/creates room → loads history → binds listeners
- `sendMessage(text)` — sends via REST first, then emits socket event
- `sendText()` — unified send method called by the UI (handles both text and image)
- `markRead(messageId)` — deduplicated with a `Set<int>` to prevent duplicate API calls

#### `chat_socket_service.dart`
Thin wrapper around `socket_io_client`:
- `connect(token)` — creates socket with JWT in `auth` header
- `joinChat`, `sendMessage`, `sendTyping`, `stopTyping`, `markRead` — typed emit helpers
- Exposes `Stream`s for each server event via `StreamController.broadcast()`

#### `chat_screen.dart` (Faculty)
Stateless `GetView<ChatController>`. Scaffold contains:
- `ChatAppBar` — reactive title/status via `Obx`
- Error banner — its own `Obx`
- `ListView` of messages — its own `Obx`
- Input field wired to `controller.textController`

---

## Student Campus Chat

**Location:** `lib/feature/student/campus/`

Built to mirror the faculty architecture with student-specific state management and a dedicated inbox layer.

### Inbox (`campus_inbox/`)

#### `InboxController` (`GetxController`)
- Fetches all chat rooms from `GET /chat` on init
- Stores `currentUserId` from `SharedPreferenceHelper` to compute display names
- `displayName(room)` — returns the other participant's username for personal chats, or the group name for groups
- `avatarInitial(room)` — first letter of display name for the avatar fallback
- `filteredChats` — computed getter that applies `activeFilter` (All / Personal / Group) and `searchQuery`

#### `InboxScreen` (`GetView<InboxController>`)
- `Get.delete` + `Get.put` in `build()` to guarantee a fresh instance on every navigation
- Search bar feeds `controller.searchQuery`
- `InboxFilterTabs` — reactive tab row (All / Personal / Group)
- `InboxChatTile` — taps navigate to `CampusChatScreen` passing `{chatId, chatName, isGroup}`

### Chat Room (`chat/`)

#### `StudentCampusChatController` (`GetxController`)
Core reactive state:
```dart
final userId = 0.obs;
final chatId = RxnInt();
final isGroup = false.obs;
final isLoading = false.obs;
final isSocketReady = false.obs;
final typingUserIds = <int>{}.obs;
final messages = <StudentChatMessageModel>[].obs;
final selectedImagePath = ''.obs;
final errorMessage = RxnString();
final currentRoom = Rxn<StudentChatRoomModel>();
final TextEditingController textController;   // disposed in onClose()
```

**`initialize(Map? args)` flow:**

```
initialize(args)
  │
  ├─ Guard: skip if already initializing or same chat already loaded
  │
  ├─ _loadCurrentUser()     → reads userId from SharedPreferences
  ├─ _resolveChat()         → GET /chat/:id OR POST /chat (create new)
  │     └─ backfill _receiverIds from participants if empty
  ├─ _bindSocketListeners() → subscribes to all socket streams (once)
  ├─ _connectSocket()       → connect OR reuse existing connection → joinChat
  └─ _loadMessageHistory()  → GET /chat/:id/messages (REST fallback)
```

**`sendText()` flow:**
```
sendText()
  ├─ if image selected → sendImageMessage()
  └─ if text present  → sendMessage(text)
      ├─ POST /chat/messages (REST — creates DB record)
      ├─ _upsertMessage(response)  → adds to messages list
      └─ socket.sendMessage(receiverIds, content, type)
```

#### `StudentChatSocketService`
Identical pattern to the faculty `ChatSocketService`:
- `connect(token)` — `socket_io_client` with JWT auth
- All emits and stream subscriptions are typed
- `typingResponse` / `stopTyping` streams drive the `typingUserIds` set in the controller

#### `StudentChatApiService`
REST layer:
- `getChatRooms()` — lists all rooms
- `getChatById(id)` — single room with participants
- `createChat(receiverIds, chatName?)` — creates personal or group chat
- `getChatMessages(chatId, page, limit)` — paginated history
- `sendChatMessage(chatId, content)` — REST message send

#### `StudentChatRepository`
Bridges `StudentChatApiService` and `StudentChatSocketService`. The controller only depends on the repository, never on the services directly.

### Chat Screen (`CampusChatScreen`)

`GetView<StudentCampusChatController>` — **stateless**. Controller is manually `Get.delete` + `Get.put` in `build()` to ensure a fresh instance per navigation.

Widget tree:
```
Scaffold
├─ CampusChatAppBar      ← Obx wraps title row (reactive name + status)
├─ _ErrorBanner          ← its own Obx
├─ _MessageList          ← its own Obx (loading / empty / list)
│    └─ ListView.builder
│         └─ _buildItem()
│              ├─ ChatTextBubble(senderName: ...)
│              └─ ChatImageBubble(senderName: ...)
└─ CampusChatInputField  ← non-reactive (plain widget)
```

### Chat Bubbles

`ChatTextBubble` and `ChatImageBubble` both accept an optional `senderName`:

| Situation | `senderName` |
|-----------|-------------|
| My own message | `null` (no label) |
| Personal chat, other person | `null` (no label) |
| Group chat, other person | `msg.sender.username` |

In group chats, each sender's name is rendered in a **deterministic color** derived from `name.hashCode % colorPalette.length` — the same name always maps to the same color across all messages, mimicking WhatsApp/Telegram behavior.

---

## Shared Concepts

### Idempotent `initialize()`

Both controllers guard against double-initialization:

```dart
if (_isInitializing) return;
if (_initializedChatKey == nextChatKey && messages.isNotEmpty) return;
```

The `_initializedChatKey` is a string like `"chat:5"` built from the chatId. This prevents redundant socket reconnects and API calls during hot reloads.

### GetX Instance Management

Because `CampusChatScreen` and `InboxScreen` are `GetView` (stateless), there is no `initState`/`dispose`. Instead, both screens manually:

```dart
if (Get.isRegistered<T>()) Get.delete<T>(force: true);
Get.put(T());
```

This guarantees a fresh, correctly-scoped controller on every navigation — avoiding the stale-instance type mismatch crash that plagued the earlier `Obx` wrapping a stale `RxList<ChatModel>`.

### Scoped `Obx` — Never Wrap Scaffold

The critical GetX rule enforced throughout:

```dart
// ❌ WRONG — Obx lambda has no direct .value reads at this level
return Obx(() => Scaffold(body: SomeOtherWidget()));

// ✅ CORRECT — each reactive widget has its own Obx
return Scaffold(
  appBar: Obx(() => Text(controller.title)),   // reads .value here
  body: Obx(() => _buildBody()),               // reads .value here
);
```

### `receiverIds` Backfill

When navigating from the Inbox (which passes only `chatId`), `_receiverIds` starts as `[]`. After `_resolveChat()` fetches the full room object, the controller backfills:

```dart
if (_receiverIds.isEmpty && currentRoom.value != null) {
  _receiverIds = currentRoom.value!.participants
      .where((p) => p.user.id != userId.value)
      .map((p) => p.user.id)
      .toList();
}
```

This is required because the backend's `sendMessage` socket event always validates that `receiverIds` is non-empty.

---

## Key Bugs Fixed

| Bug | Root Cause | Fix |
|-----|-----------|-----|
| `RxList<ChatModel>` type mismatch in `Obx` | Stale GetX controller from a previous navigation was still registered; its `chats` field was typed differently | `Get.delete(force: true)` before `Get.put` on every navigation |
| Spinner never cleared | `isLoading` was set to `true` before connecting the socket; the socket `chatHistory` event that cleared it arrived before `isLoading` was observed by the UI's `Obx` | Set `isLoading = false` initially; the socket and REST path both clear it on completion |
| `receiverIds is required` socket error | Inbox navigation only passes `chatId`; `_receiverIds` was never populated | Backfill `_receiverIds` from `currentRoom.participants` after `_resolveChat()` |
| Chat showing ID instead of name | Personal chats have `name: null` from the API | `displayName()` helper resolves the other participant's `username` for personal chats |
| `Obx` throws "no observables" | Outer `Obx(() => Scaffold(...))` had no `.value` reads in its own closure | Removed outer `Obx`; each child widget that reads reactive state has its own scoped `Obx` |
| Double-initialization on hot reload | `addPostFrameCallback` fires on every rebuild | `_isInitializing` flag + `_initializedChatKey` string guard |

---

## Architecture Decisions

### Why separate student chat vs. core chat?

The faculty chat lives in `lib/core/chat/` and is potentially shared across roles. The student campus chat was extracted into `lib/feature/student/campus/chat/` because:
- The student flow has an **Inbox screen** with filtering (All / Personal / Group)
- The student `StudentChatRoomModel` includes richer `participants` data needed for display-name resolution
- Future student-specific features (e.g., union-room auto-join) won't pollute the shared core

### Why REST + Socket for sending?

Messages are sent via **REST first**, then emitted via socket:
1. REST guarantees a database record with a real `id` even if the socket event is lost
2. The socket emit notifies **other participants** in real time
3. The REST response is `_upsertMessage`-ed locally so the sender sees their message immediately without waiting for the `newMessage` socket event

### Why `TextEditingController` in GetX controller?

Owning the `TextEditingController` inside `GetxController.onClose()` eliminates the need for `StatefulWidget` in the chat screen. The controller's lifecycle is already tied to the route — when the route pops, `onClose()` fires and the text controller is disposed cleanly.

import 'package:intl/intl.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastTime;
  final int unread;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastTime,
    this.unread = 0,
  });
}

class ChatMessage {
  final String id;
  final String from; // 'me' | 'other'
  final String text;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.from,
    required this.text,
    required this.time,
  });
}

final DateFormat hm = DateFormat('HH:mm');

final mockConversations = <Conversation>[
  Conversation(
    id: 'c1',
    name: 'Ayşe Demir',
    lastMessage: 'Yarın 15:00 uygun olur mu?',
    lastTime: DateTime.now().subtract(const Duration(minutes: 12)),
    unread: 2,
  ),
  Conversation(
    id: 'c2',
    name: 'ABC Koleji',
    lastMessage: 'Görüşme için teşekkürler.',
    lastTime: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Conversation(
    id: 'c3',
    name: 'Mehmet K.',
    lastMessage: 'CV’ni aldım.',
    lastTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
];

final mockMessages = <String, List<ChatMessage>>{
  'c1': [
    ChatMessage(id: 'm1', from: 'other', text: 'Merhaba!', time: DateTime.now().subtract(const Duration(minutes: 30))),
    ChatMessage(id: 'm2', from: 'me', text: 'Selam 👋', time: DateTime.now().subtract(const Duration(minutes: 28))),
    ChatMessage(id: 'm3', from: 'other', text: 'Yarın 15:00 uygun olur mu?', time: DateTime.now().subtract(const Duration(minutes: 12))),
  ],
  'c2': [
    ChatMessage(id: 'm1', from: 'other', text: 'Görüşme için teşekkürler.', time: DateTime.now().subtract(const Duration(hours: 4))),
  ],
  'c3': [
    ChatMessage(id: 'm1', from: 'other', text: 'CV’ni aldım.', time: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
  ],
};

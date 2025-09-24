import 'package:flutter/material.dart';
import 'messages_list_page.dart';
import 'chat_page.dart';

class MessagesShell extends StatelessWidget {
  const MessagesShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      // İç navigator: üst/alt bar sabit kalır
      onGenerateRoute: (settings) {
        if (settings.name == '/chat' && settings.arguments is ChatArgs) {
          final args = settings.arguments as ChatArgs;
          return MaterialPageRoute(builder: (_) => ChatPage(args: args));
        }
        return MaterialPageRoute(builder: (_) => const MessagesListPage());
      },
    );
  }
}

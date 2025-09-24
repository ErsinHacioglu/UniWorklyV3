import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mock_data.dart';
import 'chat_page.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final filtered = mockConversations.where((c) {
      final inName = c.name.toLowerCase().contains(_query.toLowerCase());
      final inMsg = c.lastMessage.toLowerCase().contains(_query.toLowerCase());
      return _query.isEmpty || inName || inMsg;
    }).toList()
      ..sort((a, b) => b.lastTime.compareTo(a.lastTime)); // kronolojik

    return Column(
      children: [
        // ÜST BARA ALTINA SEARCH
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Kişi veya mesaj ara...',
              filled: true,
              fillColor: cs.surfaceVariant.withOpacity(0.4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final c = filtered[i];
              return ListTile(
                leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
                title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('dd.MM HH:mm').format(c.lastTime), style: Theme.of(context).textTheme.labelSmall),
                    if (c.unread > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(12)),
                        child: Text('${c.unread}', style: TextStyle(color: cs.onPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/chat', arguments: ChatArgs(id: c.id, name: c.name));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

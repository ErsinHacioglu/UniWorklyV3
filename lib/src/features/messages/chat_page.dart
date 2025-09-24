import 'package:flutter/material.dart';
import 'mock_data.dart';

class ChatArgs {
  final String id;
  final String name;
  ChatArgs({required this.id, required this.name});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.args});
  final ChatArgs args;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final msgs = List<ChatMessage>.from(mockMessages[widget.args.id] ?? []);

    return Column(
      children: [
        // ÜST BARIN ALTINDA GERİ BUTONU + KİŞİ ADI (küçük)
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          decoration: BoxDecoration(color: cs.surface, border: Border(bottom: BorderSide(color: cs.outlineVariant))),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 4),
              CircleAvatar(radius: 14, child: Text(widget.args.name.isNotEmpty ? widget.args.name[0] : '?')),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.args.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),

        // MESAJLAR
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            reverse: false,
            itemCount: msgs.length,
            itemBuilder: (context, i) {
              final m = msgs[i];
              final isMe = m.from == 'me';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isMe ? cs.primary : cs.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isMe ? 14 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 14),
                    ),
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(color: isMe ? cs.onPrimary : cs.onSurface),
                  ),
                ),
              );
            },
          ),
        ),

        // MESAJ GİRİŞİ
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      filled: true,
                      fillColor: cs.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    final text = _ctl.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      (mockMessages[widget.args.id] ??= []).add(
                        ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), from: 'me', text: text, time: DateTime.now()),
                      );
                    });
                    _ctl.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

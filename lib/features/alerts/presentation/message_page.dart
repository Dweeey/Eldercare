import 'package:flutter/material.dart';

/// Simple in-app message screen to chat with the watch user.
/// This is UI-only (no backend/SMS integration) but gives you
/// a realistic chat experience you can extend later.
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(fromYou: false, text: 'Hi, I am okay here.'),
    const _ChatMessage(fromYou: true, text: 'Great! Remember to take your meds at 8 PM.'),
    const _ChatMessage(fromYou: false, text: 'Okay, thank you.'),
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(fromYou: true, text: text));
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final align = msg.fromYou ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final bubbleColor = msg.fromYou ? Colors.blue : Colors.grey.shade200;
                final textColor = msg.fromYou ? Colors.white : Colors.black87;

                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        msg.text,
                        style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool fromYou;
  final String text;

  const _ChatMessage({required this.fromYou, required this.text});
}

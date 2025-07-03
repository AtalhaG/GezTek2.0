import 'package:flutter/material.dart';

class MessageTasarim extends StatefulWidget {
  final String kisiAdi;
  final String kisiId;
  final String profilResmi;

  const MessageTasarim({
    super.key,
    required this.kisiAdi,
    required this.kisiId,
    required this.profilResmi,
  });

  @override
  State<MessageTasarim> createState() => _MessageTasarimState();
}

class _MessageTasarimState extends State<MessageTasarim> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Örnek mesaj verileri (gerçek uygulamada bu veriler API'den gelecek)
  final List<Map<String, dynamic>> _messages = [
    {
      'message': 'Merhaba, nasılsınız?',
      'isMe': true,
      'time': '14:30',
      'isRead': true,
    },
    {
      'message': 'İyiyim, teşekkürler! Siz nasılsınız?',
      'isMe': false,
      'time': '14:31',
      'isRead': true,
    },
    {
      'message': 'Ben de iyiyim. Tur hakkında bilgi almak istiyorum.',
      'isMe': true,
      'time': '14:32',
      'isRead': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.profilResmi),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kisiAdi,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Çevrimiçi',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message['isMe'] ? Colors.green : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['message'],
              style: TextStyle(
                color: message['isMe'] ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message['time'],
                  style: TextStyle(
                    color: message['isMe'] ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                if (message['isMe']) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message['isRead'] ? Icons.done_all : Icons.done,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green,
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                // Mesaj gönderme işlemi burada yapılacak
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


import 'package:flutter/material.dart';
import 'message_tasarim.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Örnek mesaj listesi (gerçek uygulamada API'den gelecek)
    final List<Map<String, dynamic>> conversations = [
      {
        'kisiAdi': 'Ahmet Yılmaz',
        'kisiId': '1',
        'profilResmi': 'https://via.placeholder.com/50',
        'sonMesaj': 'Tur hakkında bilgi almak istiyorum.',
        'zaman': '14:32',
        'okunmamis': true,
      },
      {
        'kisiAdi': 'Ayşe Demir',
        'kisiId': '2',
        'profilResmi': 'https://via.placeholder.com/50',
        'sonMesaj': 'Yarın görüşelim mi?',
        'zaman': '12:15',
        'okunmamis': false,
      },
      {
        'kisiAdi': 'Mehmet Kaya',
        'kisiId': '3',
        'profilResmi': 'https://via.placeholder.com/50',
        'sonMesaj': 'Teşekkürler, bilgiler için.',
        'zaman': 'Dün',
        'okunmamis': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        backgroundColor: const Color(0xFF22543D),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(conversation['profilResmi']),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  conversation['kisiAdi'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  conversation['zaman'],
                  style: TextStyle(
                    fontSize: 12,
                    color: conversation['okunmamis'] 
                        ? const Color(0xFF22543D)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              conversation['sonMesaj'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: conversation['okunmamis'] 
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageTasarim(
                    kisiAdi: conversation['kisiAdi'],
                    kisiId: conversation['kisiId'],
                    profilResmi: conversation['profilResmi'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
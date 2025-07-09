import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../controllers/group_service.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';

class GroupChat extends StatefulWidget {
  final GrupModel grup;

  const GroupChat({super.key, required this.grup});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<GrupMesajModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  // Tema renkleri
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F6F9);

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await GroupService.getGroupMessages(widget.grup.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Mesajlar yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingMessages),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context)!;
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      bool success = await GroupService.sendMessageToTour(
        turId: widget.grup.id,
        mesaj: messageText,
        gonderenId: currentUser.id,
        gonderenAdi: currentUser.fullName,
      );

      if (success) {
        await _loadMessages();
      } else {
        _messageController.text = messageText; // Mesajı geri koy
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.messageNotSent),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _messageController.text = messageText; // Mesajı geri koy
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSendingMessage}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  String _formatTime(String tarihi, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(tarihi);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return l10n.unknown;
    }
  }

  bool _isCurrentUser(String gonderenId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return gonderenId == userProvider.currentUser?.id;
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg = isDark ? theme.scaffoldBackgroundColor : backgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final bubbleMe = isDark ? darkGreen : primaryColor;
    final bubbleOther = isDark ? Colors.grey[800]! : Colors.white;
    final bubbleOtherText = isDark ? Colors.white : Colors.black87;
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputBorder =
        isDark ? darkGreen.withOpacity(0.2) : primaryColor.withOpacity(0.1);
    final iconColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bubbleMe, bubbleMe.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.grup.turAdi.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.grup.turAdi,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.grup.katilimcilar.length} ${l10n.participants} • ${l10n.tourGroup}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: bubbleMe,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => _showGroupInfo(),
                tooltip: l10n.groupInformation,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadMessages,
                tooltip: l10n.refresh,
              ),
            ],
          ),
          body: Column(
            children: [
              // Tur bilgi kartı
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bubbleMe.withOpacity(0.1),
                      bubbleMe.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bubbleMe.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tour, color: bubbleMe, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.groupParticipatingInTour,
                        style: TextStyle(
                          fontSize: 14,
                          color: bubbleMe,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.people, color: bubbleMe, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.grup.katilimcilar.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: bubbleMe,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                l10n.loadingMessages,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : _messages.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: bubbleMe.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: bubbleMe,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noMessagesYet,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentUser?.fullName != null
                                    ? l10n.helloSendFirstMessage
                                    : l10n.sendFirstMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildMessageBubble(
                              message,
                              index,
                              bubbleMe,
                              bubbleOther,
                              bubbleOtherText,
                              textColor,
                              subTextColor,
                              l10n,
                            );
                          },
                        ),
              ),
              _buildMessageInput(
                bubbleMe,
                inputBg,
                inputBorder,
                iconColor,
                textColor,
                l10n,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    GrupMesajModel message,
    int index,
    Color bubbleMe,
    Color bubbleOther,
    Color bubbleOtherText,
    Color textColor,
    Color subTextColor,
    AppLocalizations l10n,
  ) {
    final isMe = _isCurrentUser(message.gonderenId);
    final isSystemMessage = message.gonderenId == 'system';

    // Önceki mesajın aynı kullanıcıdan olup olmadığını kontrol et
    final previousMessage = index > 0 ? _messages[index - 1] : null;
    final isSequentialMessage =
        previousMessage?.gonderenId == message.gonderenId;

    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: bubbleOther,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 14, color: subTextColor),
                const SizedBox(width: 6),
                Text(
                  message.mesaj,
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: isSequentialMessage ? 2 : 12,
        top: isSequentialMessage ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && !isSequentialMessage)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bubbleMe, bubbleMe.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _getInitials(message.gonderenAdi),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 40),

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && !isSequentialMessage)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.gonderenAdi,
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        isMe
                            ? LinearGradient(
                              colors: [bubbleMe, bubbleMe.withOpacity(0.8)],
                            )
                            : null,
                    color: isMe ? null : bubbleOther,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(
                        isMe ? 18 : (isSequentialMessage ? 18 : 4),
                      ),
                      bottomRight: Radius.circular(
                        isMe ? (isSequentialMessage ? 18 : 4) : 18,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.mesaj,
                        style: TextStyle(
                          color: isMe ? Colors.white : bubbleOtherText,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.tarih, l10n),
                            style: TextStyle(
                              color: isMe ? Colors.white70 : subTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    Color bubbleMe,
    Color inputBg,
    Color inputBorder,
    Color iconColor,
    Color textColor,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: inputBorder, width: 1),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: iconColor,
                      ),
                      onPressed: () {
                        // Emoji picker gelecekte eklenebilir
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.emojiPickerComingSoon),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: l10n.typeMessage,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        minLines: 1,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: iconColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.fileAttachmentComingSoon),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bubbleMe, bubbleMe.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon:
                    _isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupInfo() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.groupInformation)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('🎯 ${l10n.tourName}', widget.grup.turAdi),
              _buildInfoRow(
                '👥 ${l10n.participants}',
                '${widget.grup.katilimcilar.length} ${l10n.participants}',
              ),
              _buildInfoRow('🧭 ${l10n.guide}', widget.grup.rehberAdi),
              _buildInfoRow(
                '📅 ${l10n.created}',
                _formatDate(widget.grup.olusturmaTarihi),
              ),
              _buildInfoRow(
                '💬 ${l10n.groupID}',
                widget.grup.id.substring(0, 8) + '...',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close, style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String tarihi) {
    final l10n = AppLocalizations.of(context)!;
    try {
      final date = DateTime.parse(tarihi);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return l10n.unknown;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

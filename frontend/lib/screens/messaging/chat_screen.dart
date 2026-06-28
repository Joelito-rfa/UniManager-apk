import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationProvider.notifier).selectConversation(widget.conversation);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    ref.read(conversationProvider.notifier).sendMessage(widget.conversation.id, text);
  }

  void _toggleReaction(MessageModel message, String reaction) {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final hasReaction = message.reactions.any((r) => r.userId == userId);
    final sameReaction = message.reactions.any((r) => r.userId == userId && r.reaction == reaction);

    if (hasReaction && sameReaction) {
      ref.read(conversationProvider.notifier).removeReaction(message.id);
    } else {
      ref.read(conversationProvider.notifier).addReaction(message.id, reaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(conversationProvider);
    final authUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.displayName,
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.conversation.isPublic)
              Text(
                'Public - ${widget.conversation.audienceLabel}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showConversationInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_rounded,
                                size: 48, color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 12),
                            Text('Aucun message',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe = msg.senderId == authUser?.id;
                          return _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            isPublic: widget.conversation.isPublic,
                            onLongPress: isMe
                                ? () => _confirmDelete(msg)
                                : null,
                            onReact: (reaction) => _toggleReaction(msg, reaction),
                            theme: theme,
                          );
                        },
                      ),
          ),
          if (_showEmojiPicker)
            _EmojiPickerWidget(
              onEmojiSelected: (emoji) {
                _messageController.text += emoji;
              },
              onClose: () => setState(() => _showEmojiPicker = false),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(60)),
              ),
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Écrivez un message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MessageModel msg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer ce message ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(conversationProvider.notifier).deleteMessage(msg.id);
    }
  }

  void _showConversationInfo(BuildContext context) {
    final theme = Theme.of(context);
    final conv = widget.conversation;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conv.displayName, style: theme.textTheme.titleMedium),
            if (conv.isPublic) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.public_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Conversation publique', style: theme.textTheme.bodySmall),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Visible par : ${conv.audienceLabel}', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Participants', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...conv.participants.map((p) => ListTile(
                  leading: CircleAvatar(
                    child: Text((p.userName?[0] ?? '?').toUpperCase()),
                  ),
                  title: Text(p.userName ?? ''),
                  subtitle: Text(p.userEmail ?? ''),
                  contentPadding: EdgeInsets.zero,
                )),
            if (conv.isPublic)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Tous les utilisateurs peuvent participer',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isPublic;
  final VoidCallback? onLongPress;
  final void Function(String reaction) onReact;
  final ThemeData theme;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.isPublic = false,
    this.onLongPress,
    required this.onReact,
    required this.theme,
  });

  static const _reactionEmojis = {
    'like': '👍',
    'love': '❤️',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isPublic && !isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName ?? 'Inconnu',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isMe
                          ? theme.colorScheme.onPrimary.withAlpha(180)
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.reactions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2, left: isMe ? 0 : 8, right: isMe ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: message.reactions.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(
                        _reactionEmojis[r.reaction] ?? r.reaction,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: 2, left: isMe ? 0 : 8, right: isMe ? 8 : 0),
            child: SizedBox(
              height: 28,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ReactionIcon(reaction: 'like', onTap: () => onReact('like')),
                  const SizedBox(width: 2),
                  _ReactionIcon(reaction: 'love', onTap: () => onReact('love')),
                  const SizedBox(width: 2),
                  _ReactionIcon(reaction: 'haha', onTap: () => onReact('haha')),
                  const SizedBox(width: 2),
                  _ReactionIcon(reaction: 'wow', onTap: () => onReact('wow')),
                  const SizedBox(width: 2),
                  _ReactionIcon(reaction: 'sad', onTap: () => onReact('sad')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ReactionIcon extends StatelessWidget {
  final String reaction;
  final VoidCallback onTap;

  static const _emojis = {
    'like': '👍',
    'love': '❤️',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
  };

  const _ReactionIcon({required this.reaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _emojis[reaction] ?? reaction,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _EmojiPickerWidget extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;
  final VoidCallback onClose;

  const _EmojiPickerWidget({
    required this.onEmojiSelected,
    required this.onClose,
  });

  static const _emojis = [
    '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊',
    '😇', '🙂', '😉', '😌', '😍', '🥰', '😘', '😗',
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭',
    '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
    '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤',
    '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧', '🥵',
    '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓',
    '🧐', '😕', '😟', '🙁', '😮', '😯', '😲', '😳',
    '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '😈',
    '👿', '💀', '☠️', '💩', '🤡', '👹', '👺', '👻',
    '👽', '👾', '🤖', '😺', '😸', '😹', '😻', '😼',
    '😽', '🙀', '😿', '😾', '👋', '🤚', '🖐', '✋',
    '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘',
    '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍',
    '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐',
    '🤲', '🤝', '🙏', '✍️', '💅', '🤳', '💪', '🦵',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => onEmojiSelected(_emojis[index]),
                  child: Center(
                    child: Text(_emojis[index], style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/conversation_provider.dart';
import '../../models/conversation_model.dart';
import '../../widgets/common/loading_widget.dart';

class MessagingListScreen extends ConsumerStatefulWidget {
  const MessagingListScreen({super.key});

  @override
  ConsumerState<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends ConsumerState<MessagingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationProvider.notifier).loadPrivateConversations();
      ref.read(conversationProvider.notifier).loadPublicConversations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(conversationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Nouvelle conversation',
            onPressed: () => context.push('/messaging/new'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Privées'),
            Tab(text: 'Publiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivateList(theme, state),
          _buildPublicList(theme, state),
        ],
      ),
    );
  }

  Widget _buildPrivateList(ThemeData theme, ConversationState state) {
    if (state.isLoading) return const LoadingWidget(message: 'Chargement...');
    if (state.privateConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Aucune conversation privée',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouvelle conversation'),
              onPressed: () => context.push('/messaging/new'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(conversationProvider.notifier).loadPrivateConversations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.privateConversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conv = state.privateConversations[index];
          return _ConversationTile(
            conversation: conv,
            isSelected: state.selectedConversation?.id == conv.id,
            onTap: () {
              ref.read(conversationProvider.notifier).selectConversation(conv);
              context.push('/messaging/chat/${conv.id}', extra: conv);
            },
          );
        },
      ),
    );
  }

  Widget _buildPublicList(ThemeData theme, ConversationState state) {
    if (state.isLoadingPublic) return const LoadingWidget(message: 'Chargement...');
    if (state.publicConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Aucune conversation publique',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(conversationProvider.notifier).loadPublicConversations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.publicConversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conv = state.publicConversations[index];
          return _ConversationTile(
            conversation: conv,
            isSelected: state.selectedConversation?.id == conv.id,
            onTap: () {
              ref.read(conversationProvider.notifier).selectConversation(conv);
              context.push('/messaging/chat/${conv.id}', extra: conv);
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMsg = conversation.lastMessage;

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(80),
      leading: CircleAvatar(
        backgroundColor: conversation.unreadCount > 0
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          conversation.isPublic ? Icons.campaign_rounded : Icons.chat_rounded,
          size: 20,
          color: conversation.unreadCount > 0
              ? theme.colorScheme.onPrimary
              : Colors.white,
        ),
      ),
      title: Text(
        conversation.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight:
              conversation.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: lastMsg != null
          ? Text(
              lastMsg.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            )
          : null,
      trailing: conversation.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

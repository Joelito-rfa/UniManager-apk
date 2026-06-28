import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ConversationState {
  final List<ConversationModel> privateConversations;
  final List<ConversationModel> publicConversations;
  final ConversationModel? selectedConversation;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingPublic;
  final bool isLoadingMessages;
  final String? error;
  final int currentPage;
  final int lastPage;

  const ConversationState({
    this.privateConversations = const [],
    this.publicConversations = const [],
    this.selectedConversation,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingPublic = false,
    this.isLoadingMessages = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  ConversationState copyWith({
    List<ConversationModel>? privateConversations,
    List<ConversationModel>? publicConversations,
    ConversationModel? selectedConversation,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingPublic,
    bool? isLoadingMessages,
    String? error,
    int? currentPage,
    int? lastPage,
    bool clearError = false,
  }) {
    return ConversationState(
      privateConversations: privateConversations ?? this.privateConversations,
      publicConversations: publicConversations ?? this.publicConversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPublic: isLoadingPublic ?? this.isLoadingPublic,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final DioClient _dioClient;

  ConversationNotifier(this._dioClient) : super(const ConversationState());

  Future<void> loadPrivateConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get(ApiConstants.conversations, queryParameters: {'type': 'private'});
      final data = response.data;
      final list = (data['data'] as List)
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(privateConversations: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadPublicConversations() async {
    state = state.copyWith(isLoadingPublic: true, clearError: true);
    try {
      final response = await _dioClient.get('${ApiConstants.conversations}/public');
      final data = response.data;
      final list = (data['data'] as List)
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(publicConversations: list, isLoadingPublic: false);
    } catch (e) {
      state = state.copyWith(isLoadingPublic: false, error: e.toString());
    }
  }

  Future<ConversationModel?> createConversation(List<int> userIds, {String? name}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.conversations, data: {
        'user_ids': userIds,
        if (name != null) 'name': name,
      });
      final result = response.data;
      if (result['success'] == true) {
        final conv = ConversationModel.fromJson(result['data'] as Map<String, dynamic>);
        await loadPrivateConversations();
        return conv;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<ConversationModel?> createPublicConversation({
    String? name,
    String? publicAudience,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.conversations, data: {
        'is_public': true,
        'public_audience': publicAudience ?? 'all',
        if (name != null) 'name': name,
      });
      final result = response.data;
      if (result['success'] == true) {
        final conv = ConversationModel.fromJson(result['data'] as Map<String, dynamic>);
        await loadPublicConversations();
        return conv;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> selectConversation(ConversationModel? conversation) async {
    state = state.copyWith(selectedConversation: conversation, messages: []);
    if (conversation != null) {
      await loadMessages(conversation.id);
      await markAsRead(conversation.id);
    }
  }

  Future<void> loadMessages(int conversationId, {int page = 1}) async {
    state = state.copyWith(isLoadingMessages: true);
    try {
      final response = await _dioClient.get(
        '${ApiConstants.conversations}/$conversationId/messages',
        queryParameters: {'page': page, 'per_page': 50},
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(data,
          (json) => MessageModel.fromJson(json as Map<String, dynamic>));
      final msgs = paginated.items.cast<MessageModel>();
      state = state.copyWith(
        messages: page == 1 ? msgs : [...msgs, ...state.messages],
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        isLoadingMessages: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMessages: false, error: e.toString());
    }
  }

  ConversationModel _updateLastMsg(ConversationModel c, int conversationId, MessageModel msg) {
    if (c.id != conversationId) return c;
    return ConversationModel(
      id: c.id, code: c.code, type: c.type, name: c.name,
      participants: c.participants, lastMessage: msg, unreadCount: 0,
      createdAt: c.createdAt, updatedAt: DateTime.now(),
    );
  }

  void _updateConversationLastMessage(int conversationId, MessageModel msg) {
    state = state.copyWith(
      privateConversations: state.privateConversations
          .map((c) => _updateLastMsg(c, conversationId, msg)).toList(),
      publicConversations: state.publicConversations
          .map((c) => _updateLastMsg(c, conversationId, msg)).toList(),
    );
  }

  ConversationModel _resetUnreadOf(ConversationModel c, int conversationId) {
    if (c.id != conversationId) return c;
    return ConversationModel(
      id: c.id, code: c.code, type: c.type, name: c.name,
      participants: c.participants, lastMessage: c.lastMessage, unreadCount: 0,
      createdAt: c.createdAt, updatedAt: c.updatedAt,
    );
  }

  void _resetUnread(int conversationId) {
    state = state.copyWith(
      privateConversations: state.privateConversations
          .map((c) => _resetUnreadOf(c, conversationId)).toList(),
      publicConversations: state.publicConversations
          .map((c) => _resetUnreadOf(c, conversationId)).toList(),
    );
  }

  Future<MessageModel?> sendMessage(int conversationId, String content) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.conversations}/$conversationId/messages',
        data: {'content': content},
      );
      final result = response.data;
      if (result['success'] == true) {
        final msg = MessageModel.fromJson(result['data'] as Map<String, dynamic>);
        state = state.copyWith(messages: [...state.messages, msg]);
        _updateConversationLastMessage(conversationId, msg);
        return msg;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> markAsRead(int conversationId) async {
    try {
      await _dioClient.put('${ApiConstants.conversations}/$conversationId/read');
      _resetUnread(conversationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.messages}/$messageId');
      final result = response.data;
      if (result['success'] == true) {
        state = state.copyWith(
          messages: state.messages.where((m) => m.id != messageId).toList(),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addReaction(int messageId, String reaction) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.messages}/$messageId/reactions',
        data: {'reaction': reaction},
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadMessages(state.selectedConversation!.id);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeReaction(int messageId) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConstants.messages}/$messageId/reactions',
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadMessages(state.selectedConversation!.id);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void setSelectedConversation(ConversationModel? conversation) {
    state = state.copyWith(selectedConversation: conversation);
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ConversationNotifier(dioClient);
});

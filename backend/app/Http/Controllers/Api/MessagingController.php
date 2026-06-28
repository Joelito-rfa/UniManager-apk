<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreConversationRequest;
use App\Http\Requests\StoreMessageRequest;
use App\Http\Requests\StoreReactionRequest;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Models\ConversationParticipant;
use App\Models\Message;
use App\Models\MessageReaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessagingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = auth()->id();

        $type = $request->type ?? 'private';

        if ($type === 'public') {
            $role = auth()->user()->roles->first()?->name;
            $conversations = Conversation::public()
                ->forAudience($role)
                ->with(['lastMessage.sender'])
                ->withCount('messages')
                ->orderBy('updated_at', 'desc')
                ->get();

            if ($conversations->isEmpty()) {
                $general = Conversation::firstOrCreate(
                    ['is_public' => true, 'name' => 'Général'],
                    ['type' => 'group', 'is_public' => true, 'public_audience' => 'all', 'name' => 'Général'],
                );
                $conversations = collect([$general]);
                $conversations->load(['lastMessage.sender']);
            }
        } else {
            $conversations = Conversation::private()
                ->forUser($userId)
                ->with(['participants.user', 'lastMessage.sender'])
                ->withCount('messages')
                ->orderBy('updated_at', 'desc')
                ->get();

            $conversations->load([
                'participants' => fn($q) => $q->where('user_id', $userId),
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => ConversationResource::collection($conversations),
        ]);
    }

    public function store(StoreConversationRequest $request): JsonResponse
    {
        $authId = auth()->id();

        if ($request->is_public) {
            $conversation = Conversation::create([
                'type' => 'group',
                'is_public' => true,
                'public_audience' => $request->public_audience ?? 'all',
                'name' => $request->name ?? 'Annonces publiques',
            ]);

            $conversation->load(['lastMessage.sender']);

            return response()->json([
                'success' => true,
                'message' => 'Conversation publique créée',
                'data' => new ConversationResource($conversation),
            ], 201);
        }

        $type = $request->type ?? 'direct';
        $userIds = $request->user_ids;

        if (!in_array($authId, $userIds)) {
            $userIds[] = $authId;
        }

        $userIds = array_unique($userIds);
        sort($userIds);

        if ($type === 'direct' && count($userIds) === 2) {
            $existing = Conversation::where('type', 'direct')
                ->whereHas('participants', fn($q) => $q->where('user_id', $userIds[0]))
                ->whereHas('participants', fn($q) => $q->where('user_id', $userIds[1]))
                ->whereDoesntHave('participants', fn($q) => $q->whereNotIn('user_id', $userIds))
                ->first();

            if ($existing) {
                return response()->json([
                    'success' => true,
                    'data' => new ConversationResource($existing->load(['participants.user', 'lastMessage.sender'])),
                ]);
            }
        }

        $conversation = Conversation::create([
            'type' => $type,
            'name' => $request->name ?? $this->generateConversationName($userIds),
        ]);

        foreach ($userIds as $uid) {
            ConversationParticipant::create([
                'conversation_id' => $conversation->id,
                'user_id' => $uid,
            ]);
        }

        $conversation->load(['participants.user', 'lastMessage.sender']);

        return response()->json([
            'success' => true,
            'message' => 'Conversation créée avec succès',
            'data' => new ConversationResource($conversation),
        ], 201);
    }

    public function unreadCount(): JsonResponse
    {
        $userId = auth()->id();
        $total = Conversation::private()
            ->forUser($userId)
            ->withCount(['messages as unread_count' => function ($q) use ($userId) {
                $q->where('created_at', '>', function ($sub) use ($userId) {
                    $sub->select('last_read_at')
                        ->from('conversation_participants')
                        ->whereColumn('conversation_id', 'conversations.id')
                        ->where('user_id', $userId);
                });
            }])
            ->get()
            ->sum('unread_count');

        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $total],
        ]);
    }

    public function show(Conversation $conversation): JsonResponse
    {
        $userId = auth()->id();

        if (!$conversation->is_public) {
            $isParticipant = $conversation->participants()->where('user_id', $userId)->exists();
            if (!$isParticipant) {
                return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
            }
        }

        $conversation->load(['lastMessage.sender']);
        if (!$conversation->is_public) {
            $conversation->load(['participants.user']);
        }

        return response()->json([
            'success' => true,
            'data' => new ConversationResource($conversation),
        ]);
    }

    public function messages(Request $request, Conversation $conversation): JsonResponse
    {
        $userId = auth()->id();

        if (!$conversation->is_public) {
            $isParticipant = $conversation->participants()->where('user_id', $userId)->exists();
            if (!$isParticipant) {
                return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
            }
        }

        $messages = $conversation->messages()
            ->with(['sender', 'reactions.user'])
            ->orderBy('created_at', 'asc')
            ->paginate($request->per_page ?? 50);

        return response()->json([
            'success' => true,
            'data' => MessageResource::collection($messages),
            'meta' => [
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
                'per_page' => $messages->perPage(),
                'total' => $messages->total(),
            ],
        ]);
    }

    public function sendMessage(StoreMessageRequest $request, Conversation $conversation): JsonResponse
    {
        $userId = auth()->id();

        if (!$conversation->is_public) {
            $isParticipant = $conversation->participants()->where('user_id', $userId)->exists();
            if (!$isParticipant) {
                return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
            }
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id' => $userId,
            'content' => $request->content,
        ]);

        $conversation->touch();

        $message->load(['sender', 'reactions.user']);

        return response()->json([
            'success' => true,
            'message' => 'Message envoyé',
            'data' => new MessageResource($message),
        ], 201);
    }

    public function markAsRead(Conversation $conversation): JsonResponse
    {
        $userId = auth()->id();

        ConversationParticipant::updateOrCreate(
            ['conversation_id' => $conversation->id, 'user_id' => $userId],
            ['last_read_at' => now()],
        );

        return response()->json([
            'success' => true,
            'message' => 'Marqué comme lu',
        ]);
    }

    public function destroyMessage(Message $message): JsonResponse
    {
        $userId = auth()->id();
        $user = auth()->user();

        $isOwner = $message->sender_id === $userId;
        $isAdmin = $user->hasRole('admin');

        if (!$isOwner && !$isAdmin) {
            return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
        }

        $conversationId = $message->conversation_id;
        $message->reactions()->delete();
        $message->delete();

        Conversation::where('id', $conversationId)->touch();

        return response()->json([
            'success' => true,
            'message' => 'Message supprimé',
        ]);
    }

    public function addReaction(StoreReactionRequest $request, Message $message): JsonResponse
    {
        $userId = auth()->id();

        $conversation = $message->conversation;
        $isParticipant = $conversation->participants()
            ->where('user_id', $userId)->exists();
        if (!$isParticipant && !$conversation->is_public) {
            return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
        }

        $reaction = MessageReaction::updateOrCreate(
            ['message_id' => $message->id, 'user_id' => $userId],
            ['reaction' => $request->reaction],
        );

        $reaction->load('user');

        return response()->json([
            'success' => true,
            'message' => 'Réaction ajoutée',
            'data' => [
                'id' => $reaction->id,
                'message_id' => $reaction->message_id,
                'user_id' => $reaction->user_id,
                'user_name' => $reaction->user?->name,
                'reaction' => $reaction->reaction,
            ],
        ]);
    }

    public function removeReaction(Message $message): JsonResponse
    {
        $userId = auth()->id();

        MessageReaction::where('message_id', $message->id)
            ->where('user_id', $userId)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Réaction retirée',
        ]);
    }

    public function publicConversations(Request $request): JsonResponse
    {
        $role = auth()->user()->roles->first()?->name;
        $conversations = Conversation::public()
            ->forAudience($role)
            ->with(['lastMessage.sender'])
            ->withCount('messages')
            ->orderBy('updated_at', 'desc')
            ->get();

        if ($conversations->isEmpty()) {
            $conversations = collect([
                Conversation::firstOrCreate(
                    ['is_public' => true, 'name' => 'Général'],
                    ['type' => 'group', 'is_public' => true, 'public_audience' => 'all', 'name' => 'Général'],
                ),
            ]);
            $conversations->load(['lastMessage.sender']);
        }

        return response()->json([
            'success' => true,
            'data' => ConversationResource::collection($conversations),
        ]);
    }

    private function generateConversationName(array $userIds): string
    {
        $names = \App\Models\User::whereIn('id', $userIds)->pluck('name')->toArray();
        return implode(', ', $names);
    }
}

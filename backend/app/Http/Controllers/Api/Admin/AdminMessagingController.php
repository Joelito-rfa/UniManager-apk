<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminMessagingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $conversations = Conversation::with(['participants.user', 'lastMessage.sender'])
            ->withCount('messages')
            ->orderBy('updated_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => ConversationResource::collection($conversations),
            'meta' => [
                'current_page' => $conversations->currentPage(),
                'last_page' => $conversations->lastPage(),
                'per_page' => $conversations->perPage(),
                'total' => $conversations->total(),
            ],
        ]);
    }

    public function show(Conversation $conversation): JsonResponse
    {
        $conversation->load(['participants.user', 'lastMessage.sender']);

        return response()->json([
            'success' => true,
            'data' => new ConversationResource($conversation),
        ]);
    }

    public function messages(Request $request, Conversation $conversation): JsonResponse
    {
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

    public function destroyMessage(Message $message): JsonResponse
    {
        $message->reactions()->delete();
        $message->delete();

        return response()->json([
            'success' => true,
            'message' => 'Message supprimé',
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string|max:1000',
            'type' => 'nullable|string|max:50',
        ]);

        $notification = Notification::create([
            'user_id' => auth()->id(),
            'type' => $validated['type'] ?? 'info',
            'title' => $validated['title'],
            'message' => $validated['message'],
            'data' => $request->except(['title', 'message', 'type']),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Notification créée avec succès',
            'data' => new NotificationResource($notification),
        ], 201);
    }

    public function index(Request $request): JsonResponse
    {
        $notifications = Notification::where('user_id', auth()->id())
            ->when($request->unread, fn($q) => $q->unread())
            ->when($request->type, fn($q, $v) => $q->where('type', $v))
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => NotificationResource::collection($notifications),
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
                'unread_count' => Notification::where('user_id', auth()->id())->unread()->count(),
            ],
        ]);
    }

    public function markAsRead(Notification $notification): JsonResponse
    {
        if ($notification->user_id !== auth()->id()) {
            return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
        }

        $notification->update(['read_at' => now()]);
        return response()->json([
            'success' => true,
            'message' => 'Notification marquée comme lue',
            'data' => new NotificationResource($notification),
        ]);
    }

    public function markAllAsRead(): JsonResponse
    {
        Notification::where('user_id', auth()->id())->unread()->update(['read_at' => now()]);
        return response()->json([
            'success' => true,
            'message' => 'Toutes les notifications marquées comme lues',
        ]);
    }

    public function destroy(Notification $notification): JsonResponse
    {
        if ($notification->user_id !== auth()->id()) {
            return response()->json(['success' => false, 'message' => 'L\'accès n\'est pas autorisé'], 403);
        }

        $notification->delete();
        return response()->json([
            'success' => true,
            'message' => 'Notification supprimée avec succès',
        ]);
    }

    public function unreadCount(): JsonResponse
    {
        $count = Notification::where('user_id', auth()->id())->unread()->count();
        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $count],
        ]);
    }
}

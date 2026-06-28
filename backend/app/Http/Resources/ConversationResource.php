<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ConversationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $authId = auth()->id();

        return [
            'code' => $this->code,
            'id' => $this->id,
            'type' => $this->type,
            'is_public' => (bool)$this->is_public,
            'public_audience' => $this->public_audience,
            'name' => $this->name,
            'participants' => ParticipantResource::collection($this->whenLoaded('participants')),
            'last_message' => new MessageResource($this->whenLoaded('lastMessage')),
            'unread_count' => $this->when($this->relationLoaded('participants') && $this->participants->isNotEmpty(), function () use ($authId) {
                $participant = $this->participants->firstWhere('user_id', $authId);
                if (!$participant || !$participant->last_read_at) {
                    return $this->messages_count ?? 0;
                }
                return $this->messages()
                    ->where('created_at', '>', $participant->last_read_at)
                    ->where('sender_id', '!=', $authId)
                    ->count();
            }, $this->messages_count ?? 0),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

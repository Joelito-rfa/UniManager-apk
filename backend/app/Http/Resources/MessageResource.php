<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'conversation_id' => $this->conversation_id,
            'sender_id' => $this->sender_id,
            'sender_name' => $this->sender?->name,
            'sender_avatar' => $this->sender?->avatar,
            'content' => $this->content,
            'file_path' => $this->file_path,
            'file_url' => $this->file_path ? \Illuminate\Support\Facades\Storage::disk('public')->url($this->file_path) : null,
            'file_name' => $this->file_name,
            'file_type' => $this->file_type,
            'file_size' => $this->file_size,
            'reactions' => ReactionResource::collection($this->whenLoaded('reactions')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

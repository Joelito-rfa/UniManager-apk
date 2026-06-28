<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'message_id' => $this->message_id,
            'user_id' => $this->user_id,
            'user_name' => $this->user?->name,
            'reaction' => $this->reaction,
            'created_at' => $this->created_at,
        ];
    }
}

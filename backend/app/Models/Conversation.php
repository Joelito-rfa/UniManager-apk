<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Conversation extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'type', 'name', 'is_public', 'public_audience',
    ];

    public function participants()
    {
        return $this->hasMany(ConversationParticipant::class);
    }

    public function messages()
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'desc');
    }

    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latestOfMany();
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'conversation_participants');
    }

    public function scopeForUser($query, int $userId)
    {
        return $query->whereHas('participants', fn($q) => $q->where('user_id', $userId));
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopePrivate($query)
    {
        return $query->where('is_public', false);
    }

    public function scopeForAudience($query, ?string $role)
    {
        if (!$role) return $query;
        return $query->where(function ($q) use ($role) {
            $q->whereNull('public_audience')
              ->orWhere('public_audience', 'all')
              ->orWhere('public_audience', $role);
        });
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Message extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'conversation_id', 'sender_id', 'content',
        'file_path', 'file_name', 'file_type', 'file_size',
    ];

    public function conversation()
    {
        return $this->belongsTo(Conversation::class);
    }

    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function reactions()
    {
        return $this->hasMany(MessageReaction::class);
    }
}

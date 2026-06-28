<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Notification extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'user_id', 'type', 'title', 'message', 'data', 'read_at'
    ];

    protected $casts = [
        'data' => 'array',
        'read_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeUnread($q)
    {
        return $q->whereNull('read_at');
    }
}

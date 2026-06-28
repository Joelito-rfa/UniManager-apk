<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AdminInvitationCode extends Model
{
    protected $fillable = [
        'code', 'used', 'created_by', 'used_by', 'used_at',
    ];

    protected $casts = [
        'used' => 'boolean',
        'used_at' => 'datetime',
    ];

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function usedBy()
    {
        return $this->belongsTo(User::class, 'used_by');
    }

    public static function generateCode(int $createdBy): self
    {
        $code = 'ADMIN-' . strtoupper(bin2hex(random_bytes(4)));

        return self::create([
            'code' => $code,
            'created_by' => $createdBy,
        ]);
    }

    public function markAsUsed(int $userId): void
    {
        $this->update([
            'used' => true,
            'used_by' => $userId,
            'used_at' => now(),
        ]);
    }
}

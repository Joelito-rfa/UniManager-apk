<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Profile extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'user_id', 'profileable_id', 'profileable_type', 'first_name', 'last_name',
        'date_of_birth', 'gender', 'address', 'city', 'country', 'postal_code'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function profileable()
    {
        return $this->morphTo();
    }
}

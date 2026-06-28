<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Classroom extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'name', 'code', 'capacity', 'building', 'floor', 'type'
    ];

    public function courses()
    {
        return $this->hasMany(Course::class);
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }
}

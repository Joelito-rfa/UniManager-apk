<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Department extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'name', 'code', 'description'
    ];

    public function programs()
    {
        return $this->hasMany(Program::class);
    }

    public function teachers()
    {
        return $this->hasMany(Teacher::class);
    }
}

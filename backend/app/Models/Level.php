<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Level extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'program_id', 'name', 'code'
    ];

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function students()
    {
        return $this->hasMany(Student::class);
    }
}

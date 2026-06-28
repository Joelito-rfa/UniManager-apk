<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Subject extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'program_id', 'level_id', 'teacher_id', 'name', 'code', 'description', 'credits', 'coefficient',
        'hours_total', 'status'
    ];

    protected $casts = [
        'credits' => 'integer',
        'coefficient' => 'float',
        'hours_total' => 'integer',
    ];

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }

    public function courses()
    {
        return $this->hasMany(Course::class);
    }
}

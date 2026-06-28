<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class LevelResult extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'student_id', 'level_id', 'program_id', 'academic_year',
        'total_points', 'total_coefficients', 'average_grade',
        'total_credits_obtained', 'total_credits_required',
        'mention', 'decision', 'published_at', 'validated_by',
    ];

    protected $casts = [
        'total_points' => 'float',
        'total_coefficients' => 'float',
        'average_grade' => 'float',
        'total_credits_obtained' => 'integer',
        'total_credits_required' => 'integer',
        'published_at' => 'datetime',
    ];

    public function isPublished(): bool
    {
        return !is_null($this->published_at);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function validatedBy()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }
}

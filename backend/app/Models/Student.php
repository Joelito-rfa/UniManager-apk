<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Student extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'user_id', 'program_id', 'level_id', 'student_number', 'enrollment_date',
        'date_of_birth', 'address', 'phone'
    ];

    protected $casts = [
        'enrollment_date' => 'date',
        'date_of_birth' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }

    public function enrollments()
    {
        return $this->hasMany(Enrollment::class);
    }

    public function grades()
    {
        return $this->hasManyThrough(Grade::class, Enrollment::class);
    }

    public function results()
    {
        return $this->hasMany(Result::class);
    }

    public function levelResults()
    {
        return $this->hasMany(LevelResult::class);
    }
}
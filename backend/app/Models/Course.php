<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\CourseResource;
use App\Traits\HasBusinessCode;

class Course extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'subject_id', 'teacher_id', 'classroom_id', 'level_id', 'semester', 'academic_year', 'group_name', 'status'
    ];

    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function classroom()
    {
        return $this->belongsTo(Classroom::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
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

    public function resources()
    {
        return $this->hasMany(CourseResource::class)->orderBy('order_column');
    }
}

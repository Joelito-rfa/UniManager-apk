<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Enrollment extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'student_id', 'course_id', 'enrollment_date', 'status'
    ];

    protected $casts = [
        'enrollment_date' => 'date',
    ];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function grades()
    {
        return $this->hasMany(Grade::class);
    }
}

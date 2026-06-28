<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;
use App\Enums\MentionEnum;

class Result extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'student_id', 'course_id', 'validated_by', 'semester', 'academic_year',
        'final_grade', 'mention', 'credits_obtained', 'status',
        'credit_value', 'grade_point', 'decision', 'published_at',
    ];

    protected $casts = [
        'final_grade' => 'float',
        'credit_value' => 'integer',
        'grade_point' => 'float',
        'published_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function ($result) {
            if (empty($result->mention) && $result->final_grade !== null) {
                $result->mention = MentionEnum::fromGrade($result->final_grade);
            }
        });

        static::updating(function ($result) {
            if ($result->isDirty('final_grade') && $result->final_grade !== null) {
                $result->mention = MentionEnum::fromGrade($result->final_grade);
            }
        });
    }

    public function isPublished(): bool
    {
        return !is_null($this->published_at);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function validatedBy()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }

    public function subject()
    {
        return $this->hasOneThrough(Subject::class, Course::class, 'id', 'id', 'course_id', 'subject_id');
    }
}

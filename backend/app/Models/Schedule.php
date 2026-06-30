<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Schedule extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'course_id', 'classroom_id', 'level_id', 'day_of_week', 'start_time',
        'end_time', 'type', 'group', 'session', 'status'
    ];

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function classroom()
    {
        return $this->belongsTo(Classroom::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }
}

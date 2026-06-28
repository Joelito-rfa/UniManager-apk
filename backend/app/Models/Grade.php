<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Grade extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'enrollment_id', 'graded_by', 'grade_type', 'grade_value', 'coefficient',
        'comment'
    ];

    protected $casts = [
        'grade_value' => 'float',
        'coefficient' => 'float',
    ];

    public function enrollment()
    {
        return $this->belongsTo(Enrollment::class);
    }

    public function gradedBy()
    {
        return $this->belongsTo(User::class, 'graded_by');
    }
}

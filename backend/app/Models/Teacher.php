<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Teacher extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'user_id', 'department_id', 'teacher_number', 'hire_date',
        'speciality', 'date_of_birth', 'address', 'phone'
    ];

    protected $casts = [
        'hire_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function subjects()
    {
        return $this->hasMany(Subject::class);
    }

    public function courses()
    {
        return $this->hasMany(Course::class);
    }

    public function scopeActive($q)
    {
        return $q;
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\HasBusinessCode;

class Program extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'department_id', 'name', 'code', 'description', 'duration'
    ];

    public function department()
    {
        return $this->belongsTo(Department::class);
    }

    public function levels()
    {
        return $this->hasMany(Level::class);
    }

    public function subjects()
    {
        return $this->hasMany(Subject::class);
    }

    public function students()
    {
        return $this->hasMany(Student::class);
    }
}

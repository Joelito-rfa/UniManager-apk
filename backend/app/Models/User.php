<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Notifications\Notifiable;
use App\Traits\HasBusinessCode;
use App\Notifications\ResetPassword as ResetPasswordNotification;

class User extends Authenticatable implements JWTSubject
{
    use HasRoles, Notifiable, HasBusinessCode;

    protected $fillable = [
        'code', 'name', 'email', 'password', 'phone', 'avatar', 'status', 'email_verified_at'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function sendPasswordResetNotification($token): void
    {
        $this->notify(new ResetPasswordNotification($token));
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    public function profile()
    {
        return $this->morphOne(Profile::class, 'profileable');
    }

    public function student()
    {
        return $this->hasOne(Student::class);
    }

    public function teacher()
    {
        return $this->hasOne(Teacher::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function gradedGrades()
    {
        return $this->hasMany(Grade::class, 'graded_by');
    }

    public function validatedResults()
    {
        return $this->hasMany(Result::class, 'validated_by');
    }

    public function scopeActive($q)
    {
        return $q->where('status', 'active');
    }
}

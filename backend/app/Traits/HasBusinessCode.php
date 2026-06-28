<?php

namespace App\Traits;

use App\Services\IdentifierService;

trait HasBusinessCode
{
    public static function bootHasBusinessCode(): void
    {
        static::creating(function ($model) {
            if (empty($model->code)) {
                $model->code = app(IdentifierService::class)->generate($model);
            }
        });
    }

    public function setCodeAttribute($value)
    {
        if ($this->exists && !is_null($this->attributes['code'] ?? null)) {
            return;
        }
        $this->attributes['code'] = $value;
    }

    public function scopeByCode($query, string $code)
    {
        return $query->where('code', $code);
    }

    public function scopeSearchByCode($query, string $term)
    {
        return $query->where('code', 'ilike', $term . '%');
    }
}

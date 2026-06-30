<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use App\Traits\HasBusinessCode;

class CourseResource extends Model
{
    use HasBusinessCode;

    protected $fillable = [
        'code', 'course_id', 'title', 'description', 'type',
        'file_path', 'thumbnail_path', 'file_name', 'file_size', 'mime_type',
        'url', 'duration', 'order_column', 'is_published',
    ];

    protected function casts(): array
    {
        return [
            'is_published' => 'boolean',
            'file_size' => 'integer',
            'duration' => 'integer',
            'order_column' => 'integer',
        ];
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function getThumbnailUrlAttribute(): ?string
    {
        if ($this->thumbnail_path) {
            return Storage::disk('public')->url($this->thumbnail_path);
        }
        return null;
    }

    public function getFileUrlAttribute(): ?string
    {
        if ($this->file_path) {
            return Storage::disk('public')->url($this->file_path);
        }
        return null;
    }

    public function getFileSizeFormattedAttribute(): string
    {
        if (!$this->file_size) return '—';
        $units = ['o', 'Ko', 'Mo', 'Go'];
        $size = $this->file_size;
        $unitIndex = 0;
        while ($size >= 1024 && $unitIndex < count($units) - 1) {
            $size /= 1024;
            $unitIndex++;
        }
        return round($size, 1) . ' ' . $units[$unitIndex];
    }
}

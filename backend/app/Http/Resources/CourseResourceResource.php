<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseResourceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'course_id' => $this->course_id,
            'title' => $this->title,
            'description' => $this->description,
            'type' => $this->type,
            'file_path' => $this->file_path,
            'thumbnail_path' => $this->thumbnail_path,
            'thumbnail_url' => $this->thumbnail_url,
            'file_url' => $this->file_url,
            'file_name' => $this->file_name,
            'file_size' => $this->file_size,
            'file_size_formatted' => $this->file_size_formatted,
            'mime_type' => $this->mime_type,
            'url' => $this->url,
            'duration' => $this->duration,
            'order_column' => $this->order_column,
            'is_published' => $this->is_published,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

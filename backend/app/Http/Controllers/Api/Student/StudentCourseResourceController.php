<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\CourseResourceResource;
use App\Models\Course;
use App\Models\CourseResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class StudentCourseResourceController extends Controller
{
    public function index(Course $course): JsonResponse
    {
        $resources = $course->resources()
            ->where('is_published', true)
            ->orderBy('order_column')
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseResourceResource::collection($resources),
        ]);
    }

    public function show(CourseResource $resource): JsonResponse
    {
        if (!$resource->is_published) {
            return response()->json(['success' => false, 'message' => 'La ressource est indisponible'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new CourseResourceResource($resource),
        ]);
    }

    public function download(CourseResource $resource)
    {
        if (!$resource->is_published) {
            return response()->json(['success' => false, 'message' => 'La ressource est indisponible'], 404);
        }

        if (!$resource->file_path || !Storage::disk('public')->exists($resource->file_path)) {
            return response()->json(['success' => false, 'message' => 'Le fichier est introuvable'], 404);
        }

        $filePath = Storage::disk('public')->path($resource->file_path);
        $mimeType = Storage::disk('public')->mimeType($resource->file_path) ?? 'application/octet-stream';

        $disposition = ($resource->type === 'video' || $resource->type === 'pdf') ? 'inline' : 'attachment';

        return response()->stream(function () use ($filePath) {
            $stream = fopen($filePath, 'rb');
            fpassthru($stream);
            fclose($stream);
        }, 200, [
            'Content-Type' => $mimeType,
            'Content-Disposition' => "$disposition; filename=\"{$resource->file_name}\"",
            'Content-Length' => filesize($filePath),
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization',
        ]);
    }
}

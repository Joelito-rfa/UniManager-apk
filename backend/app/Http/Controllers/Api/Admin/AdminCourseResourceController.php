<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Teacher\StoreCourseResourceRequest;
use App\Http\Requests\Teacher\UpdateCourseResourceRequest;
use App\Http\Resources\CourseResourceResource;
use App\Models\Course;
use App\Models\CourseResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class AdminCourseResourceController extends Controller
{
    public function index(Course $course): JsonResponse
    {
        $resources = $course->resources()->orderBy('order_column')->get();

        return response()->json([
            'success' => true,
            'data' => CourseResourceResource::collection($resources),
        ]);
    }

    public function store(StoreCourseResourceRequest $request, Course $course): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $path = $file->store('resources/' . $course->id, 'public');
            $data['file_path'] = $path;
            $data['file_name'] = $file->getClientOriginalName();
            $data['file_size'] = $file->getSize();
            $data['mime_type'] = $file->getMimeType();
        }

        $data['order_column'] = $data['order_column'] ?? $course->resources()->count();
        $data['is_published'] = $data['is_published'] ?? true;

        $resource = $course->resources()->create($data);

        $courseName = $course->subject?->name ?? $course->id;
        $users = User::where('id', '!=', auth()->id())->get();
        foreach ($users as $user) {
            $user->notifications()->create([
                'type' => 'resource',
                'title' => 'Nouvelle ressource disponible',
                'message' => "Une ressource \"{$resource->title}\" a été ajoutée au cours {$courseName}.",
                'data' => [
                    'resource_id' => $resource->id,
                    'course_id' => $course->id,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Ressource ajoutée avec succès',
            'data' => new CourseResourceResource($resource),
        ], 201);
    }

    public function show(CourseResource $resource): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new CourseResourceResource($resource),
        ]);
    }

    public function update(UpdateCourseResourceRequest $request, CourseResource $resource): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('file')) {
            if ($resource->file_path) {
                Storage::disk('public')->delete($resource->file_path);
            }
            $file = $request->file('file');
            $path = $file->store('resources/' . $resource->course_id, 'public');
            $data['file_path'] = $path;
            $data['file_name'] = $file->getClientOriginalName();
            $data['file_size'] = $file->getSize();
            $data['mime_type'] = $file->getMimeType();
        }

        $resource->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Ressource modifiée avec succès',
            'data' => new CourseResourceResource($resource->fresh()),
        ]);
    }

    public function destroy(CourseResource $resource): JsonResponse
    {
        if ($resource->file_path) {
            Storage::disk('public')->delete($resource->file_path);
        }

        $resource->delete();

        return response()->json([
            'success' => true,
            'message' => 'Ressource supprimée avec succès',
        ]);
    }

    public function download(CourseResource $resource)
    {
        if (!$resource->file_path || !Storage::disk('public')->exists($resource->file_path)) {
            return response()->json(['success' => false, 'message' => 'Le fichier est introuvable'], 404);
        }

        return Storage::disk('public')->download($resource->file_path, $resource->file_name);
    }
}

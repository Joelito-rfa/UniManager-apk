<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SearchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function __construct(private SearchService $searchService) {}

    public function search(Request $request): JsonResponse
    {
        $request->validate(['q' => 'required|string|max:100']);

        $results = $this->searchService->search($request->q, 10);

        return response()->json([
            'success' => true,
            'data' => $results,
        ]);
    }
}

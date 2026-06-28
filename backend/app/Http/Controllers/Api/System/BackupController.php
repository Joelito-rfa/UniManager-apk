<?php

namespace App\Http\Controllers\Api\System;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Artisan;

class BackupController extends Controller
{
    public function lastBackup(): JsonResponse
    {
        $files = Storage::disk('local')->files('backups');
        $lastBackup = null;
        $latestTime = 0;

        foreach ($files as $file) {
            $time = Storage::disk('local')->lastModified($file);
            if ($time > $latestTime) {
                $latestTime = $time;
                $lastBackup = [
                    'filename' => basename($file),
                    'size' => Storage::disk('local')->size($file),
                    'created_at' => date('c', $time),
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'last_backup' => $lastBackup,
                'backup_count' => count($files),
            ],
        ]);
    }

    public function createBackup(): JsonResponse
    {
        try {
            $filename = 'backup-' . now()->format('Y-m-d-H-i-s') . '.sql';
            $path = storage_path("app/backups/{$filename}");

            if (!is_dir(storage_path('app/backups'))) {
                mkdir(storage_path('app/backups'), 0755, true);
            }

            $command = sprintf(
                'pg_dump --host=%s --port=%s --username=%s --dbname=%s --file=%s 2>&1',
                config('database.connections.pgsql.host'),
                config('database.connections.pgsql.port'),
                config('database.connections.pgsql.username'),
                config('database.connections.pgsql.database'),
                $path
            );

            putenv("PGPASSWORD=" . config('database.connections.pgsql.password'));
            $output = shell_exec($command);
            putenv('PGPASSWORD');

            if (file_exists($path) && filesize($path) > 0) {
                return response()->json([
                    'success' => true,
                    'message' => 'Sauvegarde créée avec succès',
                    'data' => [
                        'filename' => $filename,
                        'size' => filesize($path),
                        'created_at' => now()->toIso8601String(),
                    ],
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'La sauvegarde a échoué: ' . ($output ?? 'Erreur inconnue'),
            ], 500);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la sauvegarde: ' . $e->getMessage(),
            ], 500);
        }
    }
}

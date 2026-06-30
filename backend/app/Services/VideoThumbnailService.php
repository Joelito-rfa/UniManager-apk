<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Symfony\Component\Process\Process;

class VideoThumbnailService
{
    public function generate(string $videoPath, string $disk = 'public'): ?string
    {
        $ffmpeg = $this->findFfmpeg();
        if (!$ffmpeg) {
            return null;
        }

        $videoFullPath = Storage::disk($disk)->path($videoPath);
        if (!file_exists($videoFullPath)) {
            return null;
        }

        $dir = dirname($videoFullPath);
        $filename = pathinfo($videoFullPath, PATHINFO_FILENAME);
        $thumbnailFilename = $filename . '_thumb.jpg';
        $thumbnailFullPath = $dir . DIRECTORY_SEPARATOR . $thumbnailFilename;

        $process = new Process([
            $ffmpeg,
            '-i', $videoFullPath,
            '-ss', '00:00:01',
            '-vframes', '1',
            '-q:v', '2',
            '-y',
            $thumbnailFullPath,
        ]);
        $process->setTimeout(30);
        $process->run();

        if (!$process->isSuccessful()) {
            return null;
        }

        $relativeDir = dirname($videoPath);
        $relativeThumbnailPath = ($relativeDir === '.' ? '' : $relativeDir . '/') . $thumbnailFilename;

        return $relativeThumbnailPath;
    }

    public function delete(?string $thumbnailPath, string $disk = 'public'): void
    {
        if ($thumbnailPath && Storage::disk($disk)->exists($thumbnailPath)) {
            Storage::disk($disk)->delete($thumbnailPath);
        }
    }

    private function findFfmpeg(): ?string
    {
        $process = Process::fromShellCommandline('which ffmpeg 2>/dev/null || where ffmpeg 2>nul');
        $process->run();
        if ($process->isSuccessful()) {
            $output = trim($process->getOutput());
            $lines = explode("\n", $output);
            $path = trim($lines[0]);
            if (!empty($path)) {
                return $path;
            }
        }

        $commonPaths = [
            'C:\\ffmpeg\\bin\\ffmpeg.exe',
            'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe',
            'C:\\Program Files (x86)\\ffmpeg\\bin\\ffmpeg.exe',
            '/usr/bin/ffmpeg',
            '/usr/local/bin/ffmpeg',
        ];
        foreach ($commonPaths as $path) {
            if (file_exists($path)) {
                return $path;
            }
        }

        return null;
    }
}

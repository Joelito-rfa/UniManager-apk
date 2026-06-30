<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$resources = App\Models\CourseResource::select('id','course_id','title','type','file_path','file_name','mime_type','url')->get();
echo json_encode($resources->toArray(), JSON_PRETTY_PRINT);

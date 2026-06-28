<?php

namespace App\Events;

use App\Models\Grade;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class GradePublished
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Grade $grade;

    public function __construct(Grade $grade)
    {
        $this->grade = $grade;
    }
}

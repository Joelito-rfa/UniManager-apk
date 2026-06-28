<?php

namespace App\Events;

use App\Models\LevelResult;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class LevelResultPublished
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public LevelResult $levelResult;

    public function __construct(LevelResult $levelResult)
    {
        $this->levelResult = $levelResult;
    }
}

<?php

namespace App\Events;

use App\Models\Result;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ResultPublished
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Result $result;

    public function __construct(Result $result)
    {
        $this->result = $result;
    }
}

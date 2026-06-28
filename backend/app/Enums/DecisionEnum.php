<?php

namespace App\Enums;

enum DecisionEnum: string
{
    case Admis = 'admis';
    case Rattrapage = 'rattrapage';
    case Ajourne = 'ajourne';

    public function label(): string
    {
        return match ($this) {
            self::Admis => 'Admis',
            self::Rattrapage => 'Admis avec rattrapage',
            self::Ajourne => 'Ajourné',
        };
    }
}

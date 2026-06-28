<?php

namespace App\Enums;

enum MentionEnum: string
{
    case TB = 'tres_bien';
    case Bien = 'bien';
    case AB = 'assez_bien';
    case Passable = 'passable';
    case Insuffisant = 'insuffisant';

    public function label(): string
    {
        return match ($this) {
            self::TB => 'Très Bien',
            self::Bien => 'Bien',
            self::AB => 'Assez Bien',
            self::Passable => 'Passable',
            self::Insuffisant => 'Insuffisant',
        };
    }

    public static function fromGrade(float $grade): string
    {
        return match (true) {
            $grade >= 16 => self::TB->value,
            $grade >= 14 => self::Bien->value,
            $grade >= 12 => self::AB->value,
            $grade >= 10 => self::Passable->value,
            default => self::Insuffisant->value,
        };
    }
}

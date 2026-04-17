<?php

declare(strict_types=1);

/**
 * Inner HTML for circular avatar: user photo from DB when set, else first letter of display name.
 * Call sites should JOIN users so name and avatar stay current.
 */
function avatar_circle_inner_html(?string $avatar, string $displayName): string
{
    $path = trim((string) ($avatar ?? ''));
    $name = trim($displayName);

    if ($path !== '') {
        $alt = $name !== '' ? $name : 'User';
        return '<img src="' . htmlspecialchars($path, ENT_QUOTES, 'UTF-8') . '" alt="' . htmlspecialchars($alt, ENT_QUOTES, 'UTF-8') . '">';
    }

    if ($name === '') {
        return htmlspecialchars('N');
    }

    if (function_exists('mb_substr')) {
        $first = mb_substr($name, 0, 1);
    } else {
        $first = substr($name, 0, 1);
    }

    return htmlspecialchars($first === '' ? 'N' : $first);
}

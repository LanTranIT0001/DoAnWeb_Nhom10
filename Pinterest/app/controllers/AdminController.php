<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Models\Pin;
use Core\Controller;
use Core\Database;

class AdminController extends Controller
{
    public function dashboardAction(): void
    {
        $this->requireAdmin();

        $db = Database::connection($this->config['db']);
        $pinModel = new Pin($db);
        $reportedPins = $pinModel->listReportedPins();

        $this->view('admin/dashboard', [
            'reportedPins' => $reportedPins,
        ]);
    }

    public function deletePinAction(): void
    {
        $this->requireAdmin();

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirect('admin/dashboard');
        }

        $pinId = isset($_POST['pin_id']) ? (int) $_POST['pin_id'] : 0;
        if ($pinId <= 0) {
            $this->redirect('admin/dashboard', ['msg' => 'invalid']);
        }

        $db = Database::connection($this->config['db']);
        $pinModel = new Pin($db);
        $deleted = $pinModel->deletePinByAdmin($pinId);

        $this->redirect('admin/dashboard', ['msg' => $deleted ? 'deleted' : 'error']);
    }

    /**
     * Stream pin image file from user app public/ (works when admin runs on another port than main app).
     */
    public function pinImageAction(): void
    {
        $this->requireAdmin();

        $pinId = isset($_GET['pin_id']) ? (int) $_GET['pin_id'] : 0;
        if ($pinId <= 0) {
            http_response_code(404);
            return;
        }

        $db = Database::connection($this->config['db']);
        $pinModel = new Pin($db);
        $imageUrl = $pinModel->findImageUrlForReportedPin($pinId);
        if ($imageUrl === null) {
            http_response_code(404);
            return;
        }

        if (preg_match('#^https?://#i', $imageUrl) === 1) {
            header('Location: ' . $imageUrl, true, 302);
            exit;
        }

        $userPublic = $this->resolveUserPublicRoot();
        if ($userPublic === null) {
            http_response_code(503);
            return;
        }

        $rel = str_replace(["\0", '\\'], '/', $imageUrl);
        $rel = ltrim($rel, '/');
        if ($rel === '' || strpos($rel, '..') !== false) {
            http_response_code(400);
            return;
        }

        $full = $userPublic . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $rel);
        $realBase = realpath($userPublic);
        $realFile = is_file($full) ? realpath($full) : false;
        if ($realBase === false || $realFile === false || strpos($realFile, $realBase) !== 0) {
            http_response_code(404);
            return;
        }

        $mime = function_exists('mime_content_type')
            ? (mime_content_type($realFile) ?: 'application/octet-stream')
            : 'application/octet-stream';
        header('Content-Type: ' . $mime);
        header('Cache-Control: private, max-age=3600');
        readfile($realFile);
        exit;
    }

    private function resolveUserPublicRoot(): ?string
    {
        $configured = $this->config['user_public_path'] ?? '';
        if (is_string($configured) && trim($configured) !== '') {
            $p = realpath(trim($configured));

            return $p !== false ? $p : null;
        }

        // do_an_admin/app/controllers -> dirname x3 = repo root containing do_an + do_an_admin
        $repoRoot = dirname(__DIR__, 3);
        $default = $repoRoot . DIRECTORY_SEPARATOR . 'do_an' . DIRECTORY_SEPARATOR . 'public';
        $p = realpath($default);

        return $p !== false ? $p : null;
    }

    // Trong file app/controllers/AdminController.php
public function rejectReportAction(): void
{
    $pinId = isset($_GET['pin_id']) ? (int)$_GET['pin_id'] : 0;

    if ($pinId > 0) {
        $db = \Core\Database::connection($this->config['db']);
        $pinModel = new \App\Models\Pin($db);
        $pinModel->rejectReportsByPin($pinId);
    }

    $this->redirect('admin/dashboard');
}
}

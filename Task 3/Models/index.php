<?php
require_once '../config/config.php';
require_once '../app/core/Database.php';
require_once '../app/core/Controller.php';
require_once '../app/controllers/Pins.php';
// Ví dụ Routing đơn giản
$controller = new Pins();
$controller->index();
?>
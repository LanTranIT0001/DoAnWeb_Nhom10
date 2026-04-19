-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th4 18, 2026 lúc 09:10 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `db_pinterest`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddPinToBoard` (IN `p_board_id` INT, IN `p_pin_id` INT)   BEGIN
    -- Chèn bản ghi mới vào bảng liên kết (Bỏ section_id vì bảng board_pins của mày không có cột này)
    INSERT INTO board_pins (board_id, pin_id, added_at)
    VALUES (p_board_id, p_pin_id, CURRENT_TIMESTAMP);
    
    SELECT 'Pin đã được lưu vào Board thành công!' AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateReport` (IN `p_reporter_id` INT, IN `p_target_id` INT, IN `p_reason` TEXT)   BEGIN
    -- Đổi tbl_reports thành pin_reports cho khớp table mày định nghĩa bên dưới
    INSERT INTO pin_reports (reported_by, pin_id, reason, status)
    VALUES (p_reporter_id, p_target_id, p_reason, 'PENDING');
    
    SELECT COUNT(*) as current_reports_count 
    FROM pin_reports 
    WHERE pin_id = p_target_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetChatHistory` (IN `conv_id` INT)   BEGIN
    SELECT m.*, u.username as sender_name 
    FROM messages m
    JOIN users u ON m.sender_id = u.id
    WHERE m.conversation_id = conv_id
    ORDER BY m.created_at ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetFollowingList` (IN `p_user_id` INT)   BEGIN
    SELECT u.id, u.username, u.role, f.created_at as follow_date
    FROM follows f
    JOIN users u ON f.following_id = u.id
    WHERE f.follower_id = p_user_id
    ORDER BY f.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetPinsByCategory` (IN `cat_id` INT)   BEGIN
    SELECT p.*, c.name as category_name 
    FROM pins p
    JOIN categories c ON p.category_id = c.id
    WHERE p.category_id = cat_id
    ORDER BY p.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTrendingPins` (IN `limit_num` INT)   BEGIN
    SELECT p.*, COUNT(l.user_id) as total_likes
    FROM pins p
    LEFT JOIN likes l ON p.id = l.pin_id
    GROUP BY p.id
    ORDER BY total_likes DESC
    LIMIT limit_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetUserStats` (IN `target_user_id` INT)   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM pins WHERE user_id = target_user_id) AS total_pins,
        (SELECT COUNT(*) FROM boards WHERE user_id = target_user_id) AS total_boards,
        (SELECT COUNT(*) FROM follows WHERE following_id = target_user_id) AS total_followers;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchPins` (IN `search_query` VARCHAR(255))   BEGIN
    SELECT * FROM pins 
    WHERE title LIKE CONCAT('%', search_query, '%') 
       OR description LIKE CONCAT('%', search_query, '%')
    ORDER BY created_at DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `boards`
--

CREATE TABLE `boards` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `privacy` enum('PUBLIC','PRIVATE') NOT NULL DEFAULT 'PUBLIC',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `boards`
--

INSERT INTO `boards` (`id`, `user_id`, `name`, `description`, `privacy`, `created_at`) VALUES
(3, 8, 'Chốn riêng', 'cafe học bài', 'PUBLIC', '2026-04-16 05:46:58'),
(4, 3, 'Three O\'clock', 'Trần Hưng Đạo', 'PUBLIC', '2026-04-16 05:51:35');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `board_pins`
--

CREATE TABLE `board_pins` (
  `board_id` int(10) UNSIGNED NOT NULL,
  `pin_id` int(10) UNSIGNED NOT NULL,
  `added_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `board_pins`
--

INSERT INTO `board_pins` (`board_id`, `pin_id`, `added_at`) VALUES
(3, 20, '2026-04-16 05:48:16'),
(4, 9, '2026-04-16 05:51:56'),
(4, 10, '2026-04-16 05:51:59');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`) VALUES
(1, 'Workspace', 'Y tuong goc lam viec'),
(2, 'Travel', 'Cam hung du lich'),
(3, 'Food', 'Mon an va decor');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `comments`
--

CREATE TABLE `comments` (
  `id` int(10) UNSIGNED NOT NULL,
  `pin_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `comments`
--

INSERT INTO `comments` (`id`, `pin_id`, `user_id`, `content`, `created_at`) VALUES
(1, 2, 4, 'dfghjk', '2026-04-15 23:34:56'),
(5, 20, 3, 'Dễ thương quá', '2026-04-16 06:23:36');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `conversations`
--

CREATE TABLE `conversations` (
  `id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `conversations`
--

INSERT INTO `conversations` (`id`, `created_at`) VALUES
(4, '2026-04-15 17:44:07'),
(6, '2026-04-15 21:33:10'),
(9, '2026-04-16 05:49:28'),
(10, '2026-04-16 05:49:45'),
(11, '2026-04-16 05:50:00'),
(12, '2026-04-16 05:55:13'),
(13, '2026-04-16 05:55:24'),
(14, '2026-04-16 06:25:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `conversation_members`
--

CREATE TABLE `conversation_members` (
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `conversation_members`
--

INSERT INTO `conversation_members` (`conversation_id`, `user_id`) VALUES
(9, 7),
(9, 8),
(10, 3),
(10, 8),
(11, 8),
(11, 9),
(12, 3),
(12, 7),
(13, 3),
(13, 9),
(14, 7),
(14, 9);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `follows`
--

CREATE TABLE `follows` (
  `id` int(10) UNSIGNED NOT NULL,
  `follower_id` int(10) UNSIGNED NOT NULL,
  `following_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `follows`
--

INSERT INTO `follows` (`id`, `follower_id`, `following_id`, `created_at`) VALUES
(3, 4, 1, '2026-04-15 23:36:25'),
(4, 9, 7, '2026-04-16 06:24:27');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `likes`
--

CREATE TABLE `likes` (
  `pin_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `likes`
--

INSERT INTO `likes` (`pin_id`, `user_id`, `created_at`) VALUES
(13, 7, '2026-04-16 07:13:37'),
(20, 3, '2026-04-16 06:23:23');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `messages`
--

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `shared_pin_id` int(10) UNSIGNED DEFAULT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `shared_pin_id`, `content`, `created_at`, `read_at`) VALUES
(53, 9, 8, NULL, 'Hello bà', '2026-04-16 05:49:39', '2026-04-15 23:30:08'),
(54, 10, 8, NULL, 'Hi', '2026-04-16 05:49:53', '2026-04-15 22:54:39'),
(55, 11, 8, NULL, 'Ê, mai đi cafe học bài khomm', '2026-04-16 05:50:21', NULL),
(56, 12, 3, NULL, 'Bà oii', '2026-04-16 05:55:18', '2026-04-15 23:30:07'),
(57, 13, 3, NULL, 'Ê con kiaaaaa', '2026-04-16 05:55:33', '2026-04-15 23:14:50'),
(58, 14, 9, NULL, 'Ơi Bích oiii', '2026-04-16 06:25:09', '2026-04-15 23:25:44'),
(59, 14, 7, NULL, 'oiiii', '2026-04-16 06:30:04', '2026-04-15 23:31:50'),
(60, 12, 7, NULL, 'oi tui nghe', '2026-04-16 07:12:05', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `actor_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` int(10) UNSIGNED NOT NULL,
  `type` varchar(20) NOT NULL,
  `pin_id` int(10) UNSIGNED DEFAULT NULL,
  `target_user_id` int(10) UNSIGNED DEFAULT NULL,
  `comment_text` text DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `notifications`
--

INSERT INTO `notifications` (`id`, `actor_id`, `receiver_id`, `type`, `pin_id`, `target_user_id`, `comment_text`, `is_read`, `read_at`, `created_at`) VALUES
(1, 3, 9, 'like', 20, NULL, NULL, 1, '2026-04-16 06:24:00', '2026-04-16 06:23:23'),
(2, 3, 9, 'comment', 20, NULL, 'Dễ thương quá', 1, '2026-04-16 06:24:00', '2026-04-16 06:23:36'),
(3, 9, 7, 'follow', NULL, NULL, NULL, 0, NULL, '2026-04-16 06:24:28'),
(4, 7, 3, 'like', 13, NULL, NULL, 1, '2026-04-16 07:14:09', '2026-04-16 07:13:37');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `pins`
--

CREATE TABLE `pins` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) NOT NULL,
  `source_link` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `category_label` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `pins`
--

INSERT INTO `pins` (`id`, `user_id`, `category_id`, `title`, `description`, `image_url`, `source_link`, `created_at`, `category_label`) VALUES
(8, 3, NULL, 'Disney', 'Phim hay', 'uploads/pins/pin_3_1776290953.jpg', NULL, '2026-04-16 05:09:13', 'Phim'),
(9, 3, NULL, 'Anh trai say hi', 'Đẹp', 'uploads/pins/pin_3_1776290991.jpg', NULL, '2026-04-16 05:09:51', 'Âm nhạc'),
(10, 3, NULL, 'Hoa tulip', 'Hoa mix', 'uploads/pins/pin_3_1776291061.jpg', NULL, '2026-04-16 05:11:01', 'Hoa'),
(11, 3, NULL, 'Món ăn Việt', 'Ẩm thực Việt Nam', 'uploads/pins/pin_3_1776291094.jpg', NULL, '2026-04-16 05:11:34', 'Ẩm thực'),
(12, 3, NULL, 'Vịnh Hạ Long', 'Danh lam thắng cảnh', 'uploads/pins/pin_3_1776291160.jpg', NULL, '2026-04-16 05:12:40', 'Du lịch'),
(13, 3, NULL, 'Em và Trịnh', 'Phim hay, nhạc cũng hay nữa.', 'uploads/pins/pin_3_1776291193.jpg', NULL, '2026-04-16 05:13:13', 'Phim'),
(14, 3, NULL, 'Chúng ta của hiện tại', 'Nhạc hay quá !!', 'uploads/pins/pin_3_1776291230.jpg', NULL, '2026-04-16 05:13:50', 'Âm nhạc'),
(15, 7, NULL, 'Poster', 'Poster phối màu nhẹ nhàng', 'uploads/pins/pin_7_1776291433.jpg', NULL, '2026-04-16 05:17:13', 'Nghệ thuật'),
(16, 7, NULL, 'Nhà hàng', 'Nhà hàng decor đẹp', 'uploads/pins/pin_7_1776291510.jpg', NULL, '2026-04-16 05:18:30', 'Ẩm thực'),
(18, 8, NULL, 'Phụ kiện', 'Bố cục gọn', 'uploads/pins/pin_8_1776291614.jpg', NULL, '2026-04-16 05:20:14', 'Du lịch'),
(19, 8, NULL, 'Nail', 'Mắt mèo', 'uploads/pins/pin_8_1776291724.jpg', NULL, '2026-04-16 05:22:04', 'Nail'),
(20, 9, NULL, 'Đồ gốm', 'Ly dễ thương, nhỏ gọn', 'uploads/pins/pin_9_1776291964.jpg', NULL, '2026-04-16 05:26:04', 'Gốm');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `pin_reports`
--

CREATE TABLE `pin_reports` (
  `id` int(10) UNSIGNED NOT NULL,
  `pin_id` int(10) UNSIGNED NOT NULL,
  `reported_by` int(10) UNSIGNED DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `pin_reports`
--

INSERT INTO `pin_reports` (`id`, `pin_id`, `reported_by`, `reason`, `status`, `created_at`) VALUES
(6, 16, 3, 'Nội dung vi phạm hoặc không phù hợp', 'PENDING', '2026-04-17 12:43:20'),
(7, 19, 3, 'Nội dung vi phạm hoặc không phù hợp', 'PENDING', '2026-04-17 12:49:12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `saved_boards`
--

CREATE TABLE `saved_boards` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `board_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `saved_pins`
--

CREATE TABLE `saved_pins` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `pin_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `saved_pins`
--

INSERT INTO `saved_pins` (`user_id`, `pin_id`, `created_at`) VALUES
(3, 9, '2026-04-16 05:51:48'),
(3, 10, '2026-04-16 05:51:42'),
(3, 16, '2026-04-16 07:12:44'),
(8, 15, '2026-04-16 05:48:07'),
(8, 20, '2026-04-16 05:48:01');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(120) NOT NULL,
  `name` varchar(120) NOT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `role` enum('USER','ADMIN') NOT NULL DEFAULT 'USER',
  `status` enum('ACTIVE','BANNED') NOT NULL DEFAULT 'ACTIVE',
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `bio` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `username`, `name`, `avatar`, `role`, `status`, `email`, `password_hash`, `created_at`, `bio`) VALUES
(3, 'minhth', 'Minh Thư', 'uploads/avatars/avatar_3_1776294468.jpg', 'USER', 'ACTIVE', '123@gmail.com', '$2y$10$zjFzeBb.kKcJiAkBYPUEhOxQAHyjwVEqIMOcZ/Ka3l1S3S6C37ZSe', '2026-04-15 15:30:32', 'Chốn riêng của Minh Thư'),
(7, 'nguynngcbchtrn', 'Nguyễn Ngọc Bích Trân', 'uploads/avatars/avatar_7_1776294578.jpg', 'USER', 'ACTIVE', '3@gmail.com', '$2y$10$vSFacYpawfh.s3GgKOOI4eA/MlBGRekx5QM5OXWhySUF6MGuNpE1u', '2026-04-16 05:14:45', 'Cô nàng cokkie'),
(8, 'trnthngclan', 'Trần Thị Ngọc Lan', 'uploads/avatars/avatar_8_1776294669.jpg', 'USER', 'ACTIVE', '4@gmail.com', '$2y$10$13DWrKykgPpkljaH10B2DO/yLKrFnzPIG7orGfcUJnZ4nKScvOVRG', '2026-04-16 05:19:01', 'Ngọc Nơ làm ngơ'),
(9, 'nguynthbotrn', 'Nguyễn Thị Bảo Trân', 'uploads/avatars/avatar_9_1776294820.jpg', 'USER', 'ACTIVE', '5@gmail.com', '$2y$10$pogWjNhqg4DXgyinXYqG1uWnLR5QgqyKFUwF5hLf5aPwMzxwcP3lC', '2026-04-16 05:22:32', 'Ếch cô đơn'),
(10, 'admin', '', NULL, 'ADMIN', 'ACTIVE', 'admin123@gmail.com', '$2y$10$.jWCmn8ykOBIfxXOoNxBU.Oc3DZ4eRW.0B.5Q.1PgbT0gExPPJwV6', '2026-04-17 12:33:48', NULL);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `boards`
--
ALTER TABLE `boards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_boards_user` (`user_id`);

--
-- Chỉ mục cho bảng `board_pins`
--
ALTER TABLE `board_pins`
  ADD PRIMARY KEY (`board_id`,`pin_id`),
  ADD KEY `fk_boardpins_pin` (`pin_id`);

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Chỉ mục cho bảng `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_comments_pin` (`pin_id`),
  ADD KEY `idx_comments_user` (`user_id`);

--
-- Chỉ mục cho bảng `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `conversation_members`
--
ALTER TABLE `conversation_members`
  ADD PRIMARY KEY (`conversation_id`,`user_id`),
  ADD KEY `fk_conv_members_user` (`user_id`);

--
-- Chỉ mục cho bảng `follows`
--
ALTER TABLE `follows`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_follow_pair` (`follower_id`,`following_id`),
  ADD KEY `idx_following` (`following_id`);

--
-- Chỉ mục cho bảng `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`pin_id`,`user_id`),
  ADD KEY `fk_likes_user` (`user_id`);

--
-- Chỉ mục cho bảng `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_messages_conversation` (`conversation_id`),
  ADD KEY `fk_messages_sender` (`sender_id`),
  ADD KEY `fk_messages_pin` (`shared_pin_id`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_receiver` (`receiver_id`),
  ADD KEY `idx_notifications_created` (`created_at`);

--
-- Chỉ mục cho bảng `pins`
--
ALTER TABLE `pins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pins_user` (`user_id`),
  ADD KEY `fk_pins_category` (`category_id`);

--
-- Chỉ mục cho bảng `pin_reports`
--
ALTER TABLE `pin_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pin_reports_pin` (`pin_id`),
  ADD KEY `idx_pin_reports_status` (`status`);

--
-- Chỉ mục cho bảng `saved_boards`
--
ALTER TABLE `saved_boards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_saved_board` (`user_id`,`board_id`),
  ADD KEY `idx_saved_boards_board` (`board_id`);

--
-- Chỉ mục cho bảng `saved_pins`
--
ALTER TABLE `saved_pins`
  ADD PRIMARY KEY (`user_id`,`pin_id`),
  ADD KEY `fk_saved_pin` (`pin_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `boards`
--
ALTER TABLE `boards`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT cho bảng `follows`
--
ALTER TABLE `follows`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT cho bảng `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `pins`
--
ALTER TABLE `pins`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT cho bảng `pin_reports`
--
ALTER TABLE `pin_reports`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `saved_boards`
--
ALTER TABLE `saved_boards`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `boards`
--
ALTER TABLE `boards`
  ADD CONSTRAINT `fk_boards_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `board_pins`
--
ALTER TABLE `board_pins`
  ADD CONSTRAINT `fk_boardpins_board` FOREIGN KEY (`board_id`) REFERENCES `boards` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_boardpins_pin` FOREIGN KEY (`pin_id`) REFERENCES `pins` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `conversation_members`
--
ALTER TABLE `conversation_members`
  ADD CONSTRAINT `fk_conv_members_conv` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_conv_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `fk_likes_pin` FOREIGN KEY (`pin_id`) REFERENCES `pins` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_messages_pin` FOREIGN KEY (`shared_pin_id`) REFERENCES `pins` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `pins`
--
ALTER TABLE `pins`
  ADD CONSTRAINT `fk_pins_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pins_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `saved_pins`
--
ALTER TABLE `saved_pins`
  ADD CONSTRAINT `fk_saved_pin` FOREIGN KEY (`pin_id`) REFERENCES `pins` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_saved_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

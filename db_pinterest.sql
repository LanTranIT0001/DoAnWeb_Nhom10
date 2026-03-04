-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: localhost
-- Thời gian đã tạo: Th3 04, 2026 lúc 02:43 PM
-- Phiên bản máy phục vụ: 10.4.28-MariaDB
-- Phiên bản PHP: 8.0.28

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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddPinToBoard` (IN `p_board_id` INT, IN `p_pin_id` INT, IN `p_section_id` INT)   BEGIN
    -- Chèn bản ghi mới vào bảng liên kết giữa Board và Pin
    INSERT INTO tbl_board_pins (board_id, pin_id, section_id, added_at)
    VALUES (p_board_id, p_pin_id, p_section_id, CURRENT_TIMESTAMP);
    
    -- Trả về thông báo xác nhận
    SELECT 'Pin đã được lưu vào Board thành công!' AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateReport` (IN `p_reporter_id` INT, IN `p_target_id` INT, IN `p_type` ENUM('PIN','USER','BOARD'), IN `p_reason` TEXT)   BEGIN
    INSERT INTO tbl_reports (reporter_id, target_id, target_type, reason)
    VALUES (p_reporter_id, p_target_id, p_type, p_reason);
    
    -- Trả về số lượng báo cáo hiện tại của mục tiêu này để Admin dễ theo dõi
    SELECT COUNT(*) as current_reports_count 
    FROM tbl_reports 
    WHERE target_id = p_target_id AND target_type = p_type;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetChatHistory` (IN `conv_id` INT)   BEGIN
    SELECT m.*, u.username as sender_name 
    FROM tbl_messages m
    JOIN tbl_users u ON m.sender_id = u.user_id
    WHERE m.conversation_id = conv_id
    ORDER BY m.created_at ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetFollowingList` (IN `p_user_id` INT)   BEGIN
    SELECT u.user_id, u.username, u.role, f.created_at as follow_date
    FROM tbl_follows f
    JOIN tbl_users u ON f.following_id = u.user_id
    WHERE f.follower_id = p_user_id
    ORDER BY f.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetPinsByCategory` (IN `cat_id` INT)   BEGIN
    SELECT p.*, c.name as category_name 
    FROM tbl_pins p
    JOIN tbl_categories c ON p.category_id = c.category_id
    WHERE p.category_id = cat_id
    ORDER BY p.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTrendingPins` (IN `limit_num` INT)   BEGIN
    SELECT p.*, COUNT(l.user_id) as total_likes
    FROM tbl_pins p
    LEFT JOIN tbl_likes l ON p.pin_id = l.pin_id
    GROUP BY p.pin_id
    ORDER BY total_likes DESC
    LIMIT limit_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetUserStats` (IN `target_user_id` INT)   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM tbl_pins WHERE creator_id = target_user_id) AS total_pins,
        (SELECT COUNT(*) FROM tbl_boards WHERE user_id = target_user_id) AS total_boards,
        (SELECT COUNT(*) FROM tbl_follows WHERE following_id = target_user_id) AS total_followers;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchPins` (IN `search_query` VARCHAR(255))   BEGIN
    SELECT * FROM tbl_pins 
    WHERE title LIKE CONCAT('%', search_query, '%') 
       OR description LIKE CONCAT('%', search_query, '%')
    ORDER BY created_at DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_boards`
--

CREATE TABLE `tbl_boards` (
  `board_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `privacy` enum('PUBLIC','PRIVATE') DEFAULT 'PUBLIC',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_board_pins`
--

CREATE TABLE `tbl_board_pins` (
  `id` int(11) NOT NULL,
  `section_id` int(11) DEFAULT NULL,
  `pin_id` int(11) NOT NULL,
  `board_id` int(11) NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_board_sections`
--

CREATE TABLE `tbl_board_sections` (
  `section_id` int(11) NOT NULL,
  `board_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_categories`
--

CREATE TABLE `tbl_categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_comments`
--

CREATE TABLE `tbl_comments` (
  `comment_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `pin_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_conversations`
--

CREATE TABLE `tbl_conversations` (
  `conversation_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_follows`
--

CREATE TABLE `tbl_follows` (
  `follower_id` int(11) NOT NULL,
  `following_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_likes`
--

CREATE TABLE `tbl_likes` (
  `pin_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_messages`
--

CREATE TABLE `tbl_messages` (
  `message_id` int(11) NOT NULL,
  `conversation_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `content` text DEFAULT NULL,
  `shared_pin_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_pins`
--

CREATE TABLE `tbl_pins` (
  `pin_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_reports`
--

CREATE TABLE `tbl_reports` (
  `report_id` int(11) NOT NULL,
  `reporter_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `target_type` enum('PIN','USER','BOARD') NOT NULL,
  `reason` text DEFAULT NULL,
  `status` enum('PENDING','RESOLVED') DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('USER','ADMIN') DEFAULT 'USER',
  `status` enum('ACTIVE','BANNED') DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_user_interests`
--

CREATE TABLE `tbl_user_interests` (
  `category_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `tbl_boards`
--
ALTER TABLE `tbl_boards`
  ADD PRIMARY KEY (`board_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `tbl_board_pins`
--
ALTER TABLE `tbl_board_pins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `section_id` (`section_id`),
  ADD KEY `pin_id` (`pin_id`),
  ADD KEY `board_id` (`board_id`);

--
-- Chỉ mục cho bảng `tbl_board_sections`
--
ALTER TABLE `tbl_board_sections`
  ADD PRIMARY KEY (`section_id`),
  ADD KEY `board_id` (`board_id`);

--
-- Chỉ mục cho bảng `tbl_categories`
--
ALTER TABLE `tbl_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Chỉ mục cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  ADD PRIMARY KEY (`comment_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pin_id` (`pin_id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Chỉ mục cho bảng `tbl_conversations`
--
ALTER TABLE `tbl_conversations`
  ADD PRIMARY KEY (`conversation_id`);

--
-- Chỉ mục cho bảng `tbl_follows`
--
ALTER TABLE `tbl_follows`
  ADD PRIMARY KEY (`follower_id`,`following_id`),
  ADD KEY `following_id` (`following_id`);

--
-- Chỉ mục cho bảng `tbl_likes`
--
ALTER TABLE `tbl_likes`
  ADD PRIMARY KEY (`pin_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `tbl_messages`
--
ALTER TABLE `tbl_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `conversation_id` (`conversation_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `shared_pin_id` (`shared_pin_id`);

--
-- Chỉ mục cho bảng `tbl_pins`
--
ALTER TABLE `tbl_pins`
  ADD PRIMARY KEY (`pin_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `creator_id` (`creator_id`);

--
-- Chỉ mục cho bảng `tbl_reports`
--
ALTER TABLE `tbl_reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `reporter_id` (`reporter_id`);

--
-- Chỉ mục cho bảng `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Chỉ mục cho bảng `tbl_user_interests`
--
ALTER TABLE `tbl_user_interests`
  ADD PRIMARY KEY (`category_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `tbl_boards`
--
ALTER TABLE `tbl_boards`
  MODIFY `board_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_board_pins`
--
ALTER TABLE `tbl_board_pins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_board_sections`
--
ALTER TABLE `tbl_board_sections`
  MODIFY `section_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_categories`
--
ALTER TABLE `tbl_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  MODIFY `comment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_conversations`
--
ALTER TABLE `tbl_conversations`
  MODIFY `conversation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_messages`
--
ALTER TABLE `tbl_messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_pins`
--
ALTER TABLE `tbl_pins`
  MODIFY `pin_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_reports`
--
ALTER TABLE `tbl_reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `tbl_boards`
--
ALTER TABLE `tbl_boards`
  ADD CONSTRAINT `tbl_boards_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Các ràng buộc cho bảng `tbl_board_pins`
--
ALTER TABLE `tbl_board_pins`
  ADD CONSTRAINT `tbl_board_pins_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `tbl_board_sections` (`section_id`),
  ADD CONSTRAINT `tbl_board_pins_ibfk_2` FOREIGN KEY (`pin_id`) REFERENCES `tbl_pins` (`pin_id`),
  ADD CONSTRAINT `tbl_board_pins_ibfk_3` FOREIGN KEY (`board_id`) REFERENCES `tbl_boards` (`board_id`);

--
-- Các ràng buộc cho bảng `tbl_board_sections`
--
ALTER TABLE `tbl_board_sections`
  ADD CONSTRAINT `tbl_board_sections_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `tbl_boards` (`board_id`);

--
-- Các ràng buộc cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  ADD CONSTRAINT `tbl_comments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`),
  ADD CONSTRAINT `tbl_comments_ibfk_2` FOREIGN KEY (`pin_id`) REFERENCES `tbl_pins` (`pin_id`),
  ADD CONSTRAINT `tbl_comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `tbl_comments` (`comment_id`);

--
-- Các ràng buộc cho bảng `tbl_follows`
--
ALTER TABLE `tbl_follows`
  ADD CONSTRAINT `tbl_follows_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `tbl_users` (`user_id`),
  ADD CONSTRAINT `tbl_follows_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Các ràng buộc cho bảng `tbl_likes`
--
ALTER TABLE `tbl_likes`
  ADD CONSTRAINT `tbl_likes_ibfk_1` FOREIGN KEY (`pin_id`) REFERENCES `tbl_pins` (`pin_id`),
  ADD CONSTRAINT `tbl_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Các ràng buộc cho bảng `tbl_messages`
--
ALTER TABLE `tbl_messages`
  ADD CONSTRAINT `tbl_messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `tbl_conversations` (`conversation_id`),
  ADD CONSTRAINT `tbl_messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `tbl_users` (`user_id`),
  ADD CONSTRAINT `tbl_messages_ibfk_3` FOREIGN KEY (`shared_pin_id`) REFERENCES `tbl_pins` (`pin_id`);

--
-- Các ràng buộc cho bảng `tbl_pins`
--
ALTER TABLE `tbl_pins`
  ADD CONSTRAINT `tbl_pins_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `tbl_categories` (`category_id`),
  ADD CONSTRAINT `tbl_pins_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Các ràng buộc cho bảng `tbl_reports`
--
ALTER TABLE `tbl_reports`
  ADD CONSTRAINT `tbl_reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Các ràng buộc cho bảng `tbl_user_interests`
--
ALTER TABLE `tbl_user_interests`
  ADD CONSTRAINT `tbl_user_interests_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `tbl_categories` (`category_id`),
  ADD CONSTRAINT `tbl_user_interests_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

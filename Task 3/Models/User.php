<?php
class User {
   
    public function register($u, $p, $e) {
        $link = taoKetNoi();
        $u = mysqli_real_escape_string($link, $u);
        $p = md5($p); 
        $e = mysqli_real_escape_string($link, $e);
        $sql = "INSERT INTO tbl_user (Username, Password, Email, Role, CreatedAt) 
                VALUES ('$u', '$p', '$e', 0, NOW())";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function login($u, $p) {
        $link = taoKetNoi();
        $u = mysqli_real_escape_string($link, $u);
        $p = md5($p);
        $sql = "SELECT * FROM tbl_user WHERE Username='$u' AND Password='$p'";
        $res = chayTruyVanTraVeDL($link, $sql);
        $user = mysqli_fetch_assoc($res);
        return $user ? $user : false;
    }

    public function logout() {
        if(session_status() === PHP_SESSION_NONE) session_start();
        session_unset();
        session_destroy();
    }

    public function updateProfile($id, $data) {
        $link = taoKetNoi();
        $email = mysqli_real_escape_string($link, $data['email']);
        $avatar = mysqli_real_escape_string($link, $data['avatar']);
        $sql = "UPDATE tbl_user SET Email = '$email', Avatar = '$avatar' WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function deleteUser($id) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_user WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function viewStatistics() {
        $link = taoKetNoi();
        $sql = "SELECT 
                (SELECT COUNT(*) FROM tbl_user) as TotalUsers,
                (SELECT COUNT(*) FROM tbl_pin) as TotalPins,
                (SELECT COUNT(*) FROM tbl_board) as TotalBoards";
        $res = chayTruyVanTraVeDL($link, $sql);
        return mysqli_fetch_assoc($res);
    }
}
?>

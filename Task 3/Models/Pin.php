<?php
class Pin {
    public function getPinsByPage($page) {
        $link = taoKetNoi();
        $from = ($page - 1) * 12; // 12 là SO_SP_TREN_TRANG (Lesson 12)
        $sql = "SELECT * FROM tbl_pin LIMIT $from, 12";
        $res = chayTruyVanTraVeDL($link, $sql);
        $data = array();
        while($r = mysqli_fetch_assoc($res)) $data[] = $r;
        return $data;
    }
    public function getDetails($id) {
        $link = taoKetNoi();
        $sql = "SELECT * FROM tbl_pin WHERE Id = $id";
        return mysqli_fetch_assoc(chayTruyVanTraVeDL($link, $sql));
    }
    public function updatePin($id, $title, $desc) {
        $link = taoKetNoi();
        $title = mysqli_real_escape_string($link, $title);
        $desc = mysqli_real_escape_string($link, $desc);
        $sql = "UPDATE tbl_pin SET Title = '$title', Description = '$desc' WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function deletePin($id) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_pin WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>
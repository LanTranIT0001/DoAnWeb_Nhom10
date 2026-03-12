<?php
class Board {
    public function createBoard($uId, $name) {
        $link = taoKetNoi();
        $name = mysqli_real_escape_string($link, $name);
        $sql = "INSERT INTO tbl_board (UserId, Name) VALUES ($uId, '$name')";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
    public function updateBoard($id, $name, $desc, $isPublic) {
        $link = taoKetNoi();
        $name = mysqli_real_escape_string($link, $name);
        $desc = mysqli_real_escape_string($link, $desc);
        $sql = "UPDATE tbl_board SET Name = '$name', Description = '$desc', IsPublic = $isPublic WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function deleteBoard($id) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_board WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function addPinToBoard($boardId, $pinId) {
        $link = taoKetNoi();
        $sql = "INSERT INTO tbl_board_pin (BoardId, PinId) VALUES ($boardId, $pinId)";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>
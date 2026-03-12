<?php
class Like {
    public function addReaction($uId, $pId) {
        $link = taoKetNoi();
        $sql = "INSERT INTO tbl_like (UserId, PinId) VALUES ($uId, $pId)";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
    public function removeReaction($uId, $pId) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_like WHERE UserId = $uId AND PinId = $pId";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>
<?php
class Comment {
    public function post($uId, $pId, $content, $parentId = 'NULL') {
        $link = taoKetNoi();
        $content = mysqli_real_escape_string($link, $content);
        $sql = "INSERT INTO tbl_comment (UserId, PinId, Content, ParentId) 
                VALUES ($uId, $pId, '$content', $parentId)";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function delete($id) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_comment WHERE Id = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>
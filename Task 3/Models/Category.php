<?php
class Category {
    public function getCategories() {
        $link = taoKetNoi();
        $sql = "SELECT * FROM tbl_category";
        $res = chayTruyVanTraVeDL($link, $sql);
        $data = array();
        while($r = mysqli_fetch_assoc($res)) $data[] = $r;
        return $data;
    }
}
?>
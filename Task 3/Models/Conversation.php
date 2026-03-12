<?php
class Conversation {
    public function getConversations($uId) {
        $link = taoKetNoi();
        $sql = "SELECT * FROM tbl_conversation WHERE User1Id = $uId OR User2Id = $uId";
        $res = chayTruyVanTraVeDL($link, $sql);
        $data = array();
        while($r = mysqli_fetch_assoc($res)) $data[] = $r;
        return $data;
    }
}
?>
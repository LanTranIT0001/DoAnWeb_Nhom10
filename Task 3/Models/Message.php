<?php
class Message {
    public function sendMessage($convId, $senderId, $msg) {
        $link = taoKetNoi();
        $msg = mysqli_real_escape_string($link, $msg);
        $sql = "INSERT INTO tbl_message (ConversationId, SenderId, Content) VALUES ($convId, $senderId, '$msg')";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
    public function deleteMessage($id) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_message WHERE MessageId = $id";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>

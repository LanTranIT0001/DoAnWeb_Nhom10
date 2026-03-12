<?php
class Follow {
    public function follow($followerId, $followingId) {
        $link = taoKetNoi();
        $sql = "INSERT INTO tbl_follow (FollowerId, FollowingId) VALUES ($followerId, $followingId)";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
    public function unfollow($followerId, $followingId) {
        $link = taoKetNoi();
        $sql = "DELETE FROM tbl_follow WHERE FollowerId = $followerId AND FollowingId = $followingId";
        return chayTruyVanKhongTraVeDL($link, $sql);
    }
}
?>
<?php
class Report {

    public function submitReport($reporterId, $targetId, $reason, $type) {
        $link = taoKetNoi();
        $reason = mysqli_real_escape_string($link, $reason);
        
        $sql = "INSERT INTO tbl_report (ReporterId, TargetId, Reason, TargetType, Status) 
                VALUES ($reporterId, $targetId, '$reason', $type, 'pending')";
        
        return chayTruyVanKhongTraVeDL($link, $sql);
    }


    public function handle($reportId, $newStatus) {
        $link = taoKetNoi();
        $newStatus = mysqli_real_escape_string($link, $newStatus); // 'resolved', 'dismissed', v.v.
        
        $sql = "UPDATE tbl_report SET Status = '$newStatus' WHERE ReportId = $reportId";
        
        return chayTruyVanKhongTraVeDL($link, $sql);
    }

    public function getReports() {
        $link = taoKetNoi();
        $sql = "SELECT * FROM tbl_report ORDER BY ReportId DESC";
        $res = chayTruyVanTraVeDL($link, $sql);
        $data = array();
        while($r = mysqli_fetch_assoc($res)) {
            $data[] = $r;
        }
        return $data;
    }
}
?>

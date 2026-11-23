# Tao file lich .ics tu cong-viec.csv va milestones.csv
# Import file .ics vao Google Calendar / Outlook / Apple Calendar.
# Cach dung:  powershell -ExecutionPolicy Bypass -File .\tao-lich.ps1 [-GioBatDau 20] [-SoGio 2]
param(
    [int]$GioBatDau = 20,          # gio bat dau lam moi ngay (gio Viet Nam)
    [double]$SoGio = 2,            # so gio lam moi ngay
    [int]$NhacTruocPhut = 30,      # nhac truoc bao nhieu phut
    [string]$Output = "lich-du-an.ics"
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$tasks = Import-Csv -Path (Join-Path $here "cong-viec.csv") -Encoding UTF8
$milestones = Import-Csv -Path (Join-Path $here "milestones.csv") -Encoding UTF8
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Escape-Ics([string]$s) {
    return $s.Replace('\', '\\').Replace(';', '\;').Replace(',', '\,').Replace("`r", '').Replace("`n", '\n')
}

# Gap dong theo RFC 5545 (toi da 75 octet moi dong)
function Fold-Line([string]$line) {
    $out = New-Object System.Text.StringBuilder
    $bytes = 0
    $limit = 73
    foreach ($ch in $line.ToCharArray()) {
        $n = $utf8.GetByteCount([string]$ch)
        if ($bytes + $n -gt $limit) {
            [void]$out.Append("`r`n ")
            $bytes = 1
        }
        [void]$out.Append($ch)
        $bytes += $n
    }
    return $out.ToString()
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("BEGIN:VCALENDAR")
$lines.Add("VERSION:2.0")
$lines.Add("PRODID:-//De tai 11//He thong gui thong bao hang loat//VI")
$lines.Add("CALSCALE:GREGORIAN")
$lines.Add("METHOD:PUBLISH")
$lines.Add("X-WR-CALNAME:De tai 11 - Thong bao hang loat")
$lines.Add("X-WR-TIMEZONE:Asia/Ho_Chi_Minh")

$stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd'T'HHmmss'Z'")
$msMap = @{}
foreach ($m in $milestones) { $msMap[$m.Ma] = $m }

$i = 0
foreach ($t in $tasks) {
    $i++
    $date = [datetime]::ParseExact($t.Ngay, "yyyy-MM-dd", $null)
    # Gio Viet Nam = UTC+7
    $startUtc = $date.AddHours($GioBatDau - 7)
    $endUtc = $startUtc.AddHours($SoGio)
    $ms = $msMap[$t.Milestone]
    $desc = "Sprint: $($ms.TieuDe)`n`nViec can lam: $($t.MoTa)`n`nNhan: $($t.Labels)`n`nCommit goi y: $($t.Commit)"

    $lines.Add("BEGIN:VEVENT")
    $lines.Add("UID:task-$i-$($t.Ngay)@detai11")
    $lines.Add("DTSTAMP:$stamp")
    $lines.Add("DTSTART:" + $startUtc.ToString("yyyyMMdd'T'HHmmss'Z'"))
    $lines.Add("DTEND:" + $endUtc.ToString("yyyyMMdd'T'HHmmss'Z'"))
    $lines.Add("SUMMARY:" + (Escape-Ics "[$($t.Milestone)] $($t.TieuDe)"))
    $lines.Add("DESCRIPTION:" + (Escape-Ics $desc))
    $lines.Add("CATEGORIES:" + (Escape-Ics $t.Milestone))
    $lines.Add("BEGIN:VALARM")
    $lines.Add("ACTION:DISPLAY")
    $lines.Add("DESCRIPTION:" + (Escape-Ics $t.TieuDe))
    $lines.Add("TRIGGER:-PT$($NhacTruocPhut)M")
    $lines.Add("END:VALARM")
    $lines.Add("END:VEVENT")
}

# Su kien ca ngay cho han chot moi sprint
foreach ($m in $milestones) {
    $d = [datetime]::ParseExact($m.HanChot, "yyyy-MM-dd", $null)
    $lines.Add("BEGIN:VEVENT")
    $lines.Add("UID:milestone-$($m.Ma)@detai11")
    $lines.Add("DTSTAMP:$stamp")
    $lines.Add("DTSTART;VALUE=DATE:" + $d.ToString("yyyyMMdd"))
    $lines.Add("DTEND;VALUE=DATE:" + $d.AddDays(1).ToString("yyyyMMdd"))
    $lines.Add("SUMMARY:" + (Escape-Ics "HAN CHOT $($m.Ma): $($m.TieuDe)"))
    $lines.Add("DESCRIPTION:" + (Escape-Ics $m.MoTa))
    $lines.Add("TRANSP:TRANSPARENT")
    $lines.Add("END:VEVENT")
}

$lines.Add("END:VCALENDAR")

$folded = $lines | ForEach-Object { Fold-Line $_ }
$path = Join-Path $here $Output
[System.IO.File]::WriteAllText($path, (($folded -join "`r`n") + "`r`n"), $utf8)
Write-Host "Da tao $path ($($tasks.Count) cong viec, $($milestones.Count) han chot)"

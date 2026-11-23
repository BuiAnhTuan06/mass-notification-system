# Tao Labels, Milestones, Issues (va tuy chon GitHub Project) tu cong-viec.csv
# Yeu cau: da dang nhap GitHub CLI (gh auth login) va repo da ton tai.
# Cach dung:
#   powershell -ExecutionPolicy Bypass -File .\tao-github.ps1 -Repo "username/ten-repo"
#   powershell -ExecutionPolicy Bypass -File .\tao-github.ps1 -Repo "username/ten-repo" -TaoProject
#   (-TaoProject can quyen: gh auth refresh -s project)
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [switch]$TaoProject,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$tasks = Import-Csv -Path (Join-Path $here "cong-viec.csv") -Encoding UTF8
$milestones = Import-Csv -Path (Join-Path $here "milestones.csv") -Encoding UTF8

function Run([string[]]$argv) {
    if ($DryRun) { Write-Host "gh $($argv -join ' ')"; return "" }
    $res = & gh @argv
    if ($LASTEXITCODE -ne 0) { throw "Loi khi chay: gh $($argv -join ' ')" }
    return $res
}

# 1. Labels
$labelColors = @{
    "setup" = "ededed"; "docs" = "0075ca"; "architecture" = "5319e7"; "database" = "fbca04"
    "docker" = "1d76db"; "api" = "0e8a16"; "rabbitmq" = "ff6600"; "worker" = "c5def5"
    "client" = "bfd4f2"; "test" = "d4c5f9"; "resilience" = "b60205"; "observability" = "006b75"
    "security" = "e11d21"; "report" = "f9d0c4"; "chore" = "cccccc"; "release" = "000000"
}
Write-Host "== Tao labels =="
foreach ($k in $labelColors.Keys) {
    Run @("label", "create", $k, "--color", $labelColors[$k], "--force", "-R", $Repo) | Out-Null
}

# 2. Milestones
Write-Host "== Tao milestones =="
$existing = @{}
if (-not $DryRun) {
    $json = & gh api "repos/$Repo/milestones?state=all&per_page=100"
    foreach ($m in ($json | ConvertFrom-Json)) { $existing[$m.title] = $m.number }
}
$msTitle = @{}
foreach ($m in $milestones) {
    $title = "$($m.Ma) - $($m.TieuDe)"
    $msTitle[$m.Ma] = $title
    if ($existing.ContainsKey($title)) { Write-Host "  da co: $title"; continue }
    Run @("api", "-X", "POST", "repos/$Repo/milestones",
        "-f", "title=$title",
        "-f", "description=$($m.MoTa)",
        "-f", "due_on=$($m.HanChot)T16:59:59Z") | Out-Null
    Write-Host "  tao: $title"
}

# 3. Issues
Write-Host "== Tao issues =="
$issueUrls = @()
foreach ($t in $tasks) {
    $d = [datetime]::ParseExact($t.Ngay, "yyyy-MM-dd", $null)
    $title = "[" + $d.ToString("dd/MM") + "] " + $t.TieuDe
    $body = @"
**Ngay du kien:** $($t.Ngay)
**Sprint:** $($msTitle[$t.Milestone])

### Mo ta
$($t.MoTa)

### Commit goi y
``$($t.Commit)``

### Hoan thanh khi
- [ ] Code/tai lieu da xong va build duoc
- [ ] Da commit va push (ghi ``Closes #<so issue>`` trong commit cuoi)
"@
    $labels = ($t.Labels -split ';') -join ','
    $url = Run @("issue", "create", "-R", $Repo, "--title", $title, "--body", $body,
        "--milestone", $msTitle[$t.Milestone], "--label", $labels)
    Write-Host "  $title -> $url"
    $issueUrls += $url
}

# 4. GitHub Project (tuy chon)
if ($TaoProject) {
    Write-Host "== Tao GitHub Project =="
    $owner = $Repo.Split('/')[0]
    $projJson = Run @("project", "create", "--owner", $owner, "--title", "De tai 11 - Thong bao hang loat", "--format", "json")
    if (-not $DryRun) {
        $proj = $projJson | ConvertFrom-Json
        foreach ($u in $issueUrls) {
            Run @("project", "item-add", "$($proj.number)", "--owner", $owner, "--url", "$u") | Out-Null
        }
        Write-Host "  Project: $($proj.url)"
    }
}

Write-Host "Xong."

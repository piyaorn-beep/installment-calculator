# ============================================================
#  DEPLOY SCRIPT — บันทึกรายรับรายจ่าย
#  ดับเบิลคลิก หรือ รันใน PowerShell
# ============================================================

$ErrorActionPreference = "Stop"
$GH = "C:\Program Files\GitHub CLI\gh.exe"
$REPO_NAME = "finance-tracker"
$PROJECT = "C:\Users\megac\OneDrive - Mega Clinic Co., Ltd\Desktop\ClaudeCode"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  บันทึกรายรับรายจ่าย — Deploy"             -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── STEP 1: Login GitHub ────────────────────────────────────
Write-Host "[1/4] ตรวจสอบ GitHub login..." -ForegroundColor Yellow
$authCheck = & $GH auth status 2>&1
if ($authCheck -match "Logged in") {
    Write-Host "      ✅ Login แล้ว" -ForegroundColor Green
} else {
    Write-Host "      ยังไม่ได้ login — กำลังเปิดเบราว์เซอร์..." -ForegroundColor Yellow
    & $GH auth login --hostname github.com --git-protocol https --web
    Write-Host "      ✅ Login สำเร็จ" -ForegroundColor Green
}

# ── STEP 2: สร้าง GitHub repo ───────────────────────────────
Write-Host ""
Write-Host "[2/4] ตรวจสอบ / สร้าง GitHub repository '$REPO_NAME'..." -ForegroundColor Yellow
Set-Location $PROJECT

$repoCheck = & $GH repo view $REPO_NAME 2>&1
if ($repoCheck -notmatch "error|not found|Could not") {
    Write-Host "      ℹ️  Repo มีอยู่แล้ว ข้ามขั้นตอนนี้" -ForegroundColor Cyan
} else {
    # init git ถ้ายังไม่มี
    if (-not (Test-Path ".git")) { git init }
    & $GH repo create $REPO_NAME --public --source=. --remote=origin --push
    Write-Host "      ✅ สร้าง repo และ push สำเร็จ" -ForegroundColor Green
}

# ── STEP 3: Push โค้ด ───────────────────────────────────────
Write-Host ""
Write-Host "[3/4] Push โค้ดล่าสุดขึ้น GitHub..." -ForegroundColor Yellow
Set-Location $PROJECT

$remoteCheck = git remote 2>&1
if ($remoteCheck -notmatch "origin") {
    $username = & $GH api user --jq ".login"
    git remote add origin "https://github.com/$username/$REPO_NAME.git"
}

git add index.html render.yaml
$statusOut = git status --porcelain
if ($statusOut) {
    git commit -m "Update finance tracker"
} else {
    Write-Host "      ℹ️  ไม่มีการเปลี่ยนแปลง" -ForegroundColor Cyan
}
git branch -M main
git push -u origin main
Write-Host "      ✅ Push สำเร็จ" -ForegroundColor Green

# ── STEP 4: เปิด Render ─────────────────────────────────────
Write-Host ""
Write-Host "[4/4] เปิด Render เพื่อ Deploy..." -ForegroundColor Yellow

$username = & $GH api user --jq ".login"
$repoUrl = "https://github.com/$username/$REPO_NAME"

Write-Host "      GitHub repo : $repoUrl" -ForegroundColor Cyan
Write-Host "      กำลังเปิด Render..." -ForegroundColor Cyan
Start-Process "https://dashboard.render.com/select-repo?type=static"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  เสร็จแล้ว! ทำสิ่งต่อไปนี้บน Render:     " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  1. Login / Sign up ด้วย GitHub"
Write-Host "  2. กด 'New +' -> Static Site"
Write-Host "  3. Connect GitHub -> เลือก repo: $REPO_NAME"
Write-Host "  4. ตั้งค่า:"
Write-Host "       Branch         : main"
Write-Host "       Publish Dir    : .  (จุดเดียว)"
Write-Host "       Build Command  : (ว่างไว้)"
Write-Host "  5. กด 'Create Static Site'"
Write-Host ""
Write-Host "  URL จะได้มาหลัง Deploy เสร็จ (~1-2 นาที)" -ForegroundColor Yellow
Write-Host "  รูปแบบ: https://$REPO_NAME.onrender.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "  อัปเดตในอนาคต: แก้ไข index.html -> รัน deploy.ps1" -ForegroundColor Cyan
Write-Host ""

Read-Host "กด Enter เพื่อปิด"

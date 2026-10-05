# ============================================================
#  CosyVoice WebUI 版本选择启动脚本
#  用法:  powershell -ExecutionPolicy Bypass -File .\run_cosyvoice.ps1
# ============================================================

$ErrorActionPreference = "Stop"

# ---------- 配置 ----------
$ProjectDir  = "E:\AI\local-voice\CosyVoice"
$VenvPython  = "$ProjectDir\.venv\Scripts\python.exe"
$WebuiPy     = "$ProjectDir\webui.py"
$ModelCache  = "E:\huggingface_cache"
$FfmpegDir   = "E:\Download\ffmpeg-master-latest-win64-gpl"
$DefaultPort = 8002

# ---------- 模型列表 ----------
$models = @(
    @{ Name = "CosyVoice 1.x (300M-SFT)";  Dir = "$ModelCache\CosyVoice-300M-SFT";  Desc = "内置7个预训练音色 + 3s极速复刻" },
    @{ Name = "CosyVoice 2 (0.5B)";        Dir = "$ModelCache\CosyVoice2-0.5B";     Desc = "零样本/跨语种复刻, 支持中英日粤韩" },
    @{ Name = "CosyVoice 3 (0.5B)";        Dir = "$ModelCache\Fun-CosyVoice3-0.5B"; Desc = "零样本复刻, 9种语言+18种方言, 指令控制" }
)

# ---------- 前置检查 ----------
if (-not (Test-Path $VenvPython)) { Write-Host "[错误] 未找到 Python 环境: $VenvPython" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $WebuiPy))    { Write-Host "[错误] 未找到 webui.py: $WebuiPy" -ForegroundColor Red; exit 1 }

# ---------- 显示菜单 ----------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "        CosyVoice WebUI 版本选择" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
for ($i = 0; $i -lt $models.Count; $i++) {
    Write-Host ("  [{0}] {1}" -f ($i + 1), $models[$i].Name) -ForegroundColor Yellow
    Write-Host ("        {0}" -f $models[$i].Desc)
}
Write-Host "  [q] 退出" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan

# ---------- 读取选择 ----------
$choice = Read-Host "请选择要运行的版本"
if ($choice -eq 'q' -or $choice -eq 'Q') { Write-Host "已退出。"; exit 0 }
$idx = 0
if (-not [int]::TryParse($choice, [ref]$idx)) { Write-Host "[错误] 无效输入" -ForegroundColor Red; exit 1 }
$idx = $idx - 1
if ($idx -lt 0 -or $idx -ge $models.Count) { Write-Host "[错误] 选择超出范围" -ForegroundColor Red; exit 1 }

$model = $models[$idx]
if (-not (Test-Path $model.Dir)) {
    Write-Host "[错误] 模型目录不存在: $($model.Dir)" -ForegroundColor Red
    Write-Host "       请确认模型已下载到 $ModelCache" -ForegroundColor Yellow
    exit 1
}

# ---------- 端口处理 ----------
$port = $DefaultPort
$t = Test-NetConnection -ComputerName 127.0.0.1 -Port $port -WarningAction SilentlyContinue
if ($t.TcpTestSucceeded) {
    Write-Host "[提示] 端口 $port 已被占用(可能有旧服务在运行)" -ForegroundColor Yellow
    $newPort = Read-Host "       输入新端口, 或直接回车自动寻找空闲端口"
    if ($newPort) {
        $port = [int]$newPort
    } else {
        for ($p = $DefaultPort + 1; $p -lt 8100; $p++) {
            $tt = Test-NetConnection -ComputerName 127.0.0.1 -Port $p -WarningAction SilentlyContinue
            if (-not $tt.TcpTestSucceeded) { $port = $p; break }
        }
    }
}

# ---------- 环境变量 ----------
$env:HF_HOME = $ModelCache
$env:HF_HUB_CACHE = $ModelCache
if (Test-Path $FfmpegDir) { $env:PATH = "$FfmpegDir;$env:PATH" }

# ---------- 启动 ----------
Write-Host ""
Write-Host "[启动] 版本: $($model.Name)" -ForegroundColor Green
Write-Host "[启动] 模型: $($model.Dir)" -ForegroundColor Green
Write-Host "[启动] 地址: http://localhost:$port" -ForegroundColor Green
Write-Host "[启动] 按 Ctrl+C 停止服务" -ForegroundColor Green
Write-Host ""
& $VenvPython $WebuiPy --port $port --model_dir $model.Dir

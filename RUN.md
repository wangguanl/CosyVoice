# 运行命令

- 项目：CosyVoice（FunAudioLLM）
- 生成时间：2026-09-09
- 运行方式：直接运行（`.venv` + Gradio WebUI）
- 硬件评估：**满足**（空卡约 15GB / RTX 4080 16GB）
  - 依据：Fun-CosyVoice3 / CosyVoice2 约 0.5B、CosyVoice-300M；常规 WebUI 远低于 16GB。

## 环境准备

```powershell
$env:Path = "E:\Programs\ffmpeg-master-latest-win64-gpl\bin;" + $env:Path
cd E:\AI\local-voice\CosyVoice
# third_party/Matcha-TTS 已内联进仓库（原为子模块），无需 git submodule update

# 已有 .venv（Python 3.10 + torch 2.3.1+cu121）。若重建：
# uv venv --python 3.10
# uv pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

模型已在 `E:\huggingface_cache\`：
- `Fun-CosyVoice3-0.5B`
- `CosyVoice2-0.5B`
- `CosyVoice-300M-SFT`

## 启动

- 推荐：`pwsh -NoProfile -File .\start.ps1`
- 说明：菜单选 CosyVoice3 / 2 / 1.x WebUI；默认第 1 项 CV3。不要默认全开。
- 等价手动：

```powershell
$env:PYTHONPATH = "E:\AI\local-voice\CosyVoice;E:\AI\local-voice\CosyVoice\third_party\Matcha-TTS"
.\.venv\Scripts\python.exe webui.py --port 8000 --model_dir E:\huggingface_cache\Fun-CosyVoice3-0.5B
```

## 验证

1. 轻验证：`from cosyvoice.cli.cosyvoice import AutoModel` 已通过；`webui.py --help` 正常。
2. WebUI 打开后完成一次克隆/合成；`nvidia-smi` 无 OOM。
3. **未长时间启动 GPU WebUI**。

## 备注 / 发现问题

- `start.ps1` 取代旧 `run_cosyvoice.ps1`（旧脚本 ffmpeg 路径曾指向 `E:\Download\...`，现统一全局 `E:\Programs\...`）。
- Windows 上 `ttsfrd` Linux wheel 可能不可用，可用默认 wetext。
- 仓库无 `pretrained_models/`，模型走 `E:\huggingface_cache`。
- PyPI 直连易超时 → 清华源；HF → `HF_ENDPOINT=https://hf-mirror.com`。

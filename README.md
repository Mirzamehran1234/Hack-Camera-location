# 📸 HACK-CAMERA v2.0 (Production Grade)
High-performance camera phishing framework with universal Linux support.

HACK-CAMERA is a sophisticated phishing tool that captures real-time snapshots from a target's camera. Engineered for researchers and security auditors, this version features an intelligent tunneling engine that works across any CPU architecture and distribution.

## 🌟 New in v2.0
- **🚀 Universal Installer**: One [setup.sh](cci:7://file://wsl.localhost/kali-linux/home/kali/tools/cam+loc/setup.sh:0:0-0:0) for all distros (Ubuntu, Kali, Arch, Fedora, Termux).
- **🤖 Architecture Aware**: Automatically downloads `x86_64`, `arm64`, or `armv7` binaries.
- **🔗 Advanced Tunneling**: 
    - **Cloudflare**: Fast, stable, no-account-needed tunneling.
    - **Ngrok**: Integrated v3 API support.
    - **Serveo**: Features **PTY Emulation** to work stable in non-TTY/background environments.
- **⚡ Async Engine**: High-speed public URL extraction without process blocking.

## 🛠️ Installation

```bash        
# Clone the repo
git clone https://github.com/Mirzamehran1234/-Hack--Camra-loucation
cd cam+loc

# Smart Setup (Detects OS, Arch, and installs all dependencies)
bash setup.sh

# Start the tool
bash hack_camera.sh

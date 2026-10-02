#!/usr/bin/env bash
set -e

echo "=== Building Cosmic Defender Standalone Executable ==="

# 1. Compile C++ Native Module
echo "[1/4] Compiling native C++ module (cosmic_native.so)..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)
cd ..

# 2. Stage Game Bundle Files
echo "[2/4] Staging Lua scripts, assets, and native binary..."
TMP_DIR=$(mktemp -d)
trap "rm -rf ${TMP_DIR}" EXIT

cp -r main.lua conf.lua src assets build/cosmic_native.so "${TMP_DIR}/"

# 3. Create Compressed Game Package
echo "[3/4] Creating self-contained game payload..."
(
    cd "${TMP_DIR}"
    python3 -c "
import zipfile, os
with zipfile.ZipFile('game.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk('.'):
        for f in files:
            if f == 'game.zip': continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, '.')
            z.write(path, rel)
"
)

# 4. Fuse LÖVE Engine Executable + Game Payload into Single Standalone Binary
echo "[4/4] Fusing LÖVE engine binary and payload into dist/cosmic_defender..."
mkdir -p dist
cat /usr/bin/love "${TMP_DIR}/game.zip" > dist/cosmic_defender
chmod +x dist/cosmic_defender

echo "=== SUCCESS! Standalone executable created at: dist/cosmic_defender ==="
ls -lh dist/cosmic_defender

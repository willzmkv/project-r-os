#!/usr/bin/env bash
set -euo pipefail

echo "==> [Task 10] Project-R ISO builder"

# Step 1: package list tests
echo "==> Running package list tests..."
bats tests/test_packages.sh

# Step 2: use pre-built packages from /aur-build/ (built as Docker image layer)
echo "==> Copying pre-built packages from image layer..."
mkdir -p project-r-repo/repo
cp /aur-build/repo/*.pkg.tar.zst project-r-repo/repo/
repo-add project-r-repo/repo/project-r-repo.db.tar.gz project-r-repo/repo/*.pkg.tar.zst

# Step 3: build the ISO (needs loop devices — must run --privileged)
echo "==> Building ISO..."
sudo mkarchiso -v -w work -o out .

# Step 4: static structure tests
echo "==> Running static ISO structure tests..."
bats tests/test_iso_build.sh --filter "profiledef|customize|project-r.conf|release"

ISO=$(ls out/project-r-*.iso 2>/dev/null | head -1)
if [[ -n "$ISO" ]]; then
    SIZE=$(stat -c%s "$ISO")
    echo "==> ISO built: $ISO ($(( SIZE / 1024 / 1024 )) MB)"
else
    echo "ERROR: ISO not found in out/"
    exit 1
fi

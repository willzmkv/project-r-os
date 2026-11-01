#!/usr/bin/env bats

# Tests that verify all required packages are declared in the package lists.
# Run: bats tests/test_packages.sh

PACKAGES_BASE="packages.x86_64"
PACKAGES_PR="project-r-packages.x86_64"

@test "base system packages present" {
    run grep -qx "base" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "linux-cachyos kernel present" {
    run grep -qx "linux-cachyos" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "KDE Plasma desktop present" {
    run grep -qx "plasma-desktop" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "flatpak present" {
    run grep -qx "flatpak" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "pr-mediad in project-r packages" {
    run grep -qx "pr-mediad" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pr-builder in project-r packages" {
    run grep -qx "pr-builder" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pr-meta in project-r packages" {
    run grep -qx "pr-meta" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pr-achieve in project-r packages" {
    run grep -qx "pr-achieve" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pr-controller in project-r packages" {
    run grep -qx "pr-controller" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pr-maestro in project-r packages" {
    run grep -qx "pr-maestro" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "emulationstation-de present" {
    run grep -qx "emulationstation-de" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "retroarch present" {
    run grep -qx "retroarch" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core mupen64plus-next present" {
    run grep -qx "libretro-mupen64plus-next" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core duckstation present" {
    run grep -qx "libretro-duckstation" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core bsnes present" {
    run grep -qx "libretro-bsnes" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core mgba present" {
    run grep -qx "libretro-mgba" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core stella2014 present" {
    run grep -qx "libretro-stella2014" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core genesis_plus_gx present" {
    run grep -qx "libretro-genesis-plus-gx" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core flycast present" {
    run grep -qx "libretro-flycast" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core beetle-saturn present" {
    run grep -qx "libretro-beetle-saturn" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core mesen present" {
    run grep -qx "libretro-mesen" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "RetroArch core melonds present" {
    run grep -qx "libretro-melonds" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "rpcs3 standalone emulator present" {
    run grep -qx "rpcs3" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "shadps4 standalone emulator present" {
    run grep -qx "shadps4" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "dolphin-emu standalone emulator present" {
    run grep -qx "dolphin-emu" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "pcsx2 standalone emulator present" {
    run grep -qx "pcsx2" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "xemu standalone emulator present" {
    run grep -qx "xemu" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "steam present" {
    run grep -qx "steam" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "heroic-games-launcher present" {
    run grep -qx "heroic-games-launcher" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "lutris present" {
    run grep -qx "lutris" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "ghostty terminal present" {
    run grep -qx "ghostty" "$PACKAGES_PR"
    [ "$status" -eq 0 ]
}

@test "nodejs build toolchain present" {
    run grep -qx "nodejs" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "python build toolchain present" {
    run grep -qx "python" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "gcc build toolchain present" {
    run grep -qx "gcc" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "cmake build toolchain present" {
    run grep -qx "cmake" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

@test "cjson library present" {
    run grep -qx "cjson" "$PACKAGES_BASE"
    [ "$status" -eq 0 ]
}

#!/usr/bin/env bats

# Tests that verify the ISO builds successfully and output is sane.
# Prerequisite: run `sudo make iso` before running these tests.
# Run: bats tests/test_iso_build.sh

OUT_DIR="out"

@test "ISO output directory exists" {
    [ -d "$OUT_DIR" ]
}

@test "ISO file was produced" {
    run ls "$OUT_DIR"/project-r-*.iso
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "ISO file is larger than 1 GB" {
    ISO=$(ls "$OUT_DIR"/project-r-*.iso | head -1)
    SIZE=$(stat -c%s "$ISO")
    [ "$SIZE" -gt 1073741824 ]
}

@test "profiledef.sh defines iso_name as project-r" {
    run grep 'iso_name="project-r"' profiledef.sh
    [ "$status" -eq 0 ]
}

@test "profiledef.sh includes x86_64 architecture" {
    run grep 'arch="x86_64"' profiledef.sh
    [ "$status" -eq 0 ]
}

@test "customize_airootfs.sh exists and is executable" {
    [ -x "airootfs/root/customize_airootfs.sh" ]
}

@test "customize_airootfs.sh creates arcade user" {
    run grep "useradd.*arcade" "airootfs/root/customize_airootfs.sh"
    [ "$status" -eq 0 ]
}

@test "customize_airootfs.sh enables auto-login" {
    run grep "autologin" "airootfs/root/customize_airootfs.sh"
    [ "$status" -eq 0 ]
}

@test "customize_airootfs.sh enables pr-mediad service" {
    run grep "systemctl enable.*pr-mediad" "airootfs/root/customize_airootfs.sh"
    [ "$status" -eq 0 ]
}

@test "customize_airootfs.sh enables pr-builder service" {
    run grep "systemctl enable.*pr-builder" "airootfs/root/customize_airootfs.sh"
    [ "$status" -eq 0 ]
}

@test "project-r.conf pacman repo included in pacman.conf" {
    run grep "project-r-repo" "pacman.conf"
    [ "$status" -eq 0 ]
}

@test "release file exists in airootfs" {
    [ -f "airootfs/etc/project-r/release" ]
}

@test "release file contains PROJECT_R_VERSION" {
    run grep "PROJECT_R_VERSION" "airootfs/etc/project-r/release"
    [ "$status" -eq 0 ]
}

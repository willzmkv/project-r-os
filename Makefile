.PHONY: iso repo clean test qemu-test

PROFILE_DIR := $(shell pwd)
OUT_DIR     := $(PROFILE_DIR)/out
WORK_DIR    := $(PROFILE_DIR)/work
REPO_DIR    := $(PROFILE_DIR)/project-r-repo

iso: repo
	@echo "==> Building Project-R ISO..."
	sudo mkarchiso -v -w "$(WORK_DIR)" -o "$(OUT_DIR)" "$(PROFILE_DIR)"
	@echo "==> ISO written to $(OUT_DIR)"

repo:
	@echo "==> Building local PKGBUILD repo..."
	$(MAKE) -C "$(REPO_DIR)"

clean:
	@echo "==> Cleaning build artifacts..."
	sudo rm -rf "$(WORK_DIR)" "$(OUT_DIR)"
	$(MAKE) -C "$(REPO_DIR)" clean

test:
	@echo "==> Running tests..."
	bats tests/test_packages.sh
	bats tests/test_iso_build.sh

qemu-test:
	@ISO=$$(ls $(OUT_DIR)/project-r-*.iso | head -1); \
	echo "==> Booting $$ISO in QEMU..."; \
	qemu-system-x86_64 -m 4G -cdrom "$$ISO" -boot d -enable-kvm -vga std

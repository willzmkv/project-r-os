.PHONY: all clean

REPO_NAME := project-r-repo
REPO_DIR  := $(shell pwd)/repo
PKGS      := $(wildcard */PKGBUILD)
PKG_DIRS  := $(patsubst %/PKGBUILD,%,$(PKGS))

.PHONY: $(PKG_DIRS)

# Explicit ordering for AUR inter-package dependencies
emulationstation-de: freeimage
pcsx2: rapidyaml

all: $(PKG_DIRS)
	@echo "==> All packages built."

$(PKG_DIRS):
	@echo "==> Building package: $@"
	mkdir -p $(REPO_DIR)
	cd $@ && makepkg -s --noconfirm --noprogressbar
	cp $@/*.pkg.tar.zst $(REPO_DIR)/
	cd $(REPO_DIR) && repo-add --new $(REPO_NAME).db.tar.gz *.pkg.tar.zst
	sudo pacman -Sy --noconfirm

clean:
	rm -rf $(REPO_DIR)
	find . -name "*.pkg.tar.zst" -delete
	find . -name "pkg" -type d -exec rm -rf {} + 2>/dev/null; true
	find . -name "src" -type d -exec rm -rf {} + 2>/dev/null; true

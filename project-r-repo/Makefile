.PHONY: all clean

REPO_NAME := project-r-repo
REPO_DIR  := $(shell pwd)/repo
PKGS      := $(wildcard */PKGBUILD)
PKG_DIRS  := $(patsubst %/PKGBUILD,%,$(PKGS))

.PHONY: $(PKG_DIRS)

all: $(REPO_DIR)/$(REPO_NAME).db.tar.gz

$(REPO_DIR)/$(REPO_NAME).db.tar.gz: $(PKG_DIRS)
	repo-add $(REPO_DIR)/$(REPO_NAME).db.tar.gz $(REPO_DIR)/*.pkg.tar.zst

$(PKG_DIRS):
	@echo "==> Building package: $@"
	mkdir -p $(REPO_DIR)
	cd $@ && makepkg -s --noconfirm
	cp $@/*.pkg.tar.zst $(REPO_DIR)/

clean:
	rm -rf $(REPO_DIR)
	find . -name "*.pkg.tar.zst" -delete
	find . -name "pkg" -type d -exec rm -rf {} + 2>/dev/null; true
	find . -name "src" -type d -exec rm -rf {} + 2>/dev/null; true

.PHONY: build
build:
	acton build $(DEP_OVERRIDES) $(TARGET)

.PHONY: build-ldep
build-ldep:
	$(MAKE) build DEP_OVERRIDES="--dep netconf=../netconf --dep yang=../acton-yang"

.PHONY: build-linux-x86_64
build-linux-x86_64:
	$(MAKE) build TARGET="--target x86_64-linux-gnu.2.27"

.PHONY: build-linux-aarch64
build-linux-aarch64:
	$(MAKE) build TARGET="--target aarch64-linux-gnu.2.27"

.PHONY: build-macos-aarch64
build-macos-aarch64:
	$(MAKE) build TARGET="--target aarch64-macos"

.PHONY: test
test:
	acton test $(DEP_OVERRIDES)

.PHONY: test-ldep
test-ldep:
	$(MAKE) test DEP_OVERRIDES="--dep netconf=../netconf --dep yang=../acton-yang"

.PHONY: pkg-upgrade
pkg-upgrade:
	acton pkg upgrade

.PHONY: download-release
download-release:
	@OS=$$(uname -s); \
	ARCH=$$(uname -m); \
	if [ "$$ARCH" = "arm64" ]; then ARCH="aarch64"; fi; \
	if [ "$$OS" = "Darwin" ]; then \
		RELEASE_FILE=ncurl-macos-$$ARCH; \
	else \
		RELEASE_FILE=ncurl-linux-$$ARCH; \
	fi; \
	echo "Downloading $$RELEASE_FILE from GitHub..."; \
	mkdir -p out/bin; \
	if ! curl -L -f -o out/bin/ncurl https://github.com/stratoweave/ncurl/releases/download/tip/$$RELEASE_FILE; then \
		echo "Error: Failed to download $$RELEASE_FILE - this platform may not have a pre-built release"; \
		exit 1; \
	fi; \
	chmod +x out/bin/ncurl; \
	echo "Download complete: out/bin/ncurl"

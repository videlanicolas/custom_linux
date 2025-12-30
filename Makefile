VERSION = 6.12.63
MAJOR_VERSION = v6.x
BUILD_DIR = kernel_build

KERNEL_FILENAME = linux-$(VERSION)
TAR = $(KERNEL_FILENAME).tar
TARBALL = $(TAR).xz
SIGNATURE = $(TAR).sign
BASE_URL = https://cdn.kernel.org/pub/linux/kernel/$(MAJOR_VERSION)

# PGP keys, verify with:
# gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org
PGP_KEY_GREGKG = 647F28654894E3BD457199BE38DBBDC86092693E
PGP_KEY_TORVALDS = ABAF11C65A2970B130ABE3C479BE3E4300411886

.PHONY: all clean verify download-keys

$(BUILD_DIR)/$(TARBALL):
	mkdir -p $(BUILD_DIR)
	curl -L $(BASE_URL)/$(TARBALL) -o $(BUILD_DIR)/$(TARBALL)

$(BUILD_DIR)/$(SIGNATURE):
	mkdir -p $(BUILD_DIR)
	curl -L $(BASE_URL)/$(SIGNATURE) -o $(BUILD_DIR)/$(SIGNATURE)

verify_and_uncompress_kernel: $(BUILD_DIR)/$(TARBALL) $(BUILD_DIR)/$(SIGNATURE)
	@echo "Verifying $(TARBALL)..."
	xz -d --keep $(BUILD_DIR)/$(TARBALL)
	gpg --verify --assert-signer $(PGP_KEY_TORVALDS) --assert-signer $(PGP_KEY_GREGKG) $(BUILD_DIR)/$(SIGNATURE) $(BUILD_DIR)/$(TAR)
	@echo "$(TARBALL) has good signature."
	@echo "Uncompressing $(TARBALL)..."
	tar xf $(BUILD_DIR)/$(TAR) -C $(BUILD_DIR)

kernel: verify_and_uncompress_kernel
	@echo "Building $(TARBALL)..."
	cd $(BUILD_DIR)/$(KERNEL_FILENAME) && make mrproper

os: kernel
	echo "Building OS"

clean:
	rm -rf $(BUILD_DIR)

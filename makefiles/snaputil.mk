ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS    += snaputil
SNAPUTIL_VERSION := 10.15.1
DEB_SNAPUTIL_V   ?= $(SNAPUTIL_VERSION)

snaputil-setup: setup
	$(call GITHUB_ARCHIVE,Diatrus,apfs,$(SNAPUTIL_VERSION),v$(SNAPUTIL_VERSION),snaputil)
	$(call EXTRACT_TAR,snaputil-$(SNAPUTIL_VERSION).tar.gz,apfs-$(SNAPUTIL_VERSION),snaputil)
	mkdir -p $(BUILD_STAGE)/snaputil/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/snaputil/.build_complete),)
snaputil:
	@echo "Using previously built snaputil."
else
snaputil: snaputil-setup
	$(CC) -arch $(MEMO_ARCH) -Os -Wall -isysroot $(TARGET_SYSROOT) $(PLATFORM_VERSION_MIN) -o $(BUILD_STAGE)/snaputil/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/snaputil $(BUILD_WORK)/snaputil/snapUtil.c
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,snaputil.xml)
endif

.PHONY: snaputil
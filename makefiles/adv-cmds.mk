ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS      += adv-cmds
ADV-CMDS_VERSION := 176

adv-cmds-setup: setup binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://opensource.apple.com/tarballs/adv_cmds/adv_cmds-$(ADV-CMDS_VERSION).tar.gz)
	$(call EXTRACT_TAR,adv_cmds-$(ADV-CMDS_VERSION).tar.gz,adv_cmds-$(ADV-CMDS_VERSION),adv-cmds)
	mkdir -p $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/adv-cmds/.build_complete),)
adv-cmds:
	@echo "Using previously built adv-cmds."
else
adv-cmds: adv-cmds-setup
	mkdir -p $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)/bin
	$(CC) $(CFLAGS) -o $(BUILD_STAGE)/adv-cmds/$(MEMO_PREFIX)/bin/stty $(BUILD_WORK)/adv-cmds/stty/*.c $(LDFLAGS)
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: adv-cmds

endif # ($(MEMO_TARGET),darwin-\*)

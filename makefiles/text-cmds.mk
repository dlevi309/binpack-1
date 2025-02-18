ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS       += text-cmds
TEXT-CMDS_VERSION := 138.100.3

text-cmds-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,text_cmds,$(TEXT-CMDS_VERSION),text_cmds-$(TEXT-CMDS_VERSION))
	$(call EXTRACT_TAR,text_cmds-$(TEXT-CMDS_VERSION).tar.gz,text_cmds-text_cmds-$(TEXT-CMDS_VERSION),text-cmds)
	sed -i 's|/usr|$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)|' $(BUILD_WORK)/text-cmds/ee/ee.c
	sed -i '/libutil.h/ s/$$/\nint expand_number(const char *buf, uint64_t *num);/' $(BUILD_WORK)/text-cmds/split/split.c
	mkdir -p $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX){/{s,}bin,$(MEMO_SUB_PREFIX)/bin}

ifneq ($(wildcard $(BUILD_WORK)/text-cmds/.build_complete),)
text-cmds:
	@echo "Using previously built text-cmds."
else
text-cmds: text-cmds-setup bzip2 xz
	-cd $(BUILD_WORK)/text-cmds; \
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/bin/cat cat/cat.c; \
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ee ee/ee.c -lncurses -DHAS_NCURSES -DHAS_UNISTD -DHAS_STDARG -DHAS_STDLIB -DHAS_SYS_WAIT; \
	for bin in cut grep head md5 sed split tail wc; do \
		EXTRAFLAGS=""; \
		if [ "$$bin" = "grep" ]; then \
			EXTRAFLAGS="-lbz2 -llzma -lz"; \
		elif [ "$$bin" = "split" ]; then \
			EXTRAFLAGS="-lutil"; \
		fi; \
		$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin $$bin/*.c $$EXTRAFLAGS; \
	done
	mv $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/md5 $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/sbin/md5
	for cmd in rmd160 sha1 sha256; do \
		$(LN_S) md5 $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/sbin/$$cmd; \
	done
	$(LN_S) grep $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/egrep
	$(LN_S) grep $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/fgrep
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
	$(LDID) -Hsha256 -S$(BUILD_MISC)/entitlements/dd.xml $(BUILD_STAGE)/text-cmds/$(MEMO_PREFIX)/bin/cat
endif

.PHONY: text-cmds

endif # ($(MEMO_TARGET),darwin-\*)

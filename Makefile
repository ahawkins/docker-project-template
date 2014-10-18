sha1=$(shell echo $(1) | sha1sum | cut -d ' ' -f 1)

BASE_IMAGES=registry.platform.saltside.io/platform/ruby \
						registry.platform.saltside.io/platform/redis
PULL_BASE_IMAGES=$(addprefix pull/,$(BASE_IMAGES))
EXPORT_BASE_IMAGES=$(addprefix export/,$(BASE_IMAGES))
IMPORT_BASE_IMAGES=$(addprefix import/,$(BASE_IMAGES))

define IMAGE_template
tmp/images/$(call sha1,$(1)):
	docker pull $(1)
	mkdir -p $$(@D)
	docker images -q $(1) > $$@

pull/$(1): tmp/images/$(call sha1,$(1))

tmp/images/$(call sha1,$(1)).tar: tmp/images/$(call sha1,$(1))
	docker save -o $$@ $(1)

export/$(1): tmp/images/$(call sha1,$(1)).tar

import/$(1): tmp/images/$(call sha1,$(1)).tar
ifeq ($$(shell docker images -q $(1)), "")
	docker load -i $$<
endif
endef

$(foreach image,$(BASE_IMAGES),$(eval $(call IMAGE_template,$(image))))

pull: $(PULL_BASE_IMAGES)
export: $(EXPORT_BASE_IMAGES)
import: $(IMPORT_BASE_IMAGES)

.PHONY: pull export import

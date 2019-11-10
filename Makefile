# This Makefile serves as a proxy for `zola` commands

SERVE_DIR := public
DIST_DIR := dist
DEV_CONFIG := config.dev.toml
PROD_CONFIG := config.toml
NOW := $(shell date)

.PHONY: serve-dev serve-prod build deploy verify-content-dates unchanged check

serve-prod:
	zola --config $(PROD_CONFIG) serve --output-dir $(SERVE_DIR)

serve-dev:
	zola --config $(DEV_CONFIG) serve --output-dir $(SERVE_DIR) --drafts

build:
	zola --config $(PROD_CONFIG) build --output-dir $(DIST_DIR)

verify-content-dates:
	bin/verify-content-dates

unchanged:
	bin/check-for-nothing-staged

check:
	shellcheck bin/*
	zola check

deploy: check unchanged verify-content-dates build
	git add content/writes $(DIST_DIR)
	git commit -m "AUTO: make deploy run on $(NOW)" --allow-empty
	bin/ship $(DIST_DIR) the-details master

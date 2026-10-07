.PHONY: all setup fmt lint test build release dmg run open quit status ci clean

all: build

setup:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/setup.sh

fmt:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/fmt.sh

lint:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/lint.sh

test:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/test.sh

build:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/build.sh debug

release:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/build.sh release

dmg:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/dmg.sh

run: open

open:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/spotterm open

quit:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/spotterm quit

status:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/spotterm status

ci:
	@chmod +x scripts/*.sh scripts/spotterm 2>/dev/null || true
	@./scripts/ci.sh

clean:
	@rm -rf build .build

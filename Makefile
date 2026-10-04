.PHONY: all setup fmt lint test build release run ci clean

all: build

setup:
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

fmt:
	@chmod +x scripts/*.sh
	@./scripts/fmt.sh

lint:
	@chmod +x scripts/*.sh
	@./scripts/lint.sh

test:
	@chmod +x scripts/*.sh
	@./scripts/test.sh

build:
	@chmod +x scripts/*.sh
	@./scripts/build.sh debug

release:
	@chmod +x scripts/*.sh
	@./scripts/build.sh release

run:
	@chmod +x scripts/*.sh
	@./scripts/run.sh

ci:
	@chmod +x scripts/*.sh
	@./scripts/ci.sh

clean:
	@rm -rf build .build

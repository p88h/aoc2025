# Advent of Code 2025 - Odin Solutions Makefile

ODIN ?= odin
BUILD_DIR := out
SRC_DIR := src

# Default target
all: build

# Build the main executable
build: | $(BUILD_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BUILD_DIR)/aoc2025

# Build with optimizations
release: | $(BUILD_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BUILD_DIR)/aoc2025 -o:speed

# Build with debug symbols
debug: | $(BUILD_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BUILD_DIR)/aoc2025 -debug

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Run a specific day (usage: make run DAY=1)
run: build
	./$(BUILD_DIR)/aoc2025 $(DAY)

# Run all implemented days
run-all: build
	@for day in 1; do \
		echo "=== Day $$day ==="; \
		./$(BUILD_DIR)/aoc2025 $$day 2>/dev/null || true; \
	done

# Check code (syntax check without building)
check:
	$(ODIN) check $(SRC_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Print help
help:
	@echo "Advent of Code 2025 - Odin Solutions"
	@echo ""
	@echo "Targets:"
	@echo "  build     - Build the project (default)"
	@echo "  release   - Build with optimizations"
	@echo "  debug     - Build with debug symbols"
	@echo "  run       - Run a specific day (DAY=N)"
	@echo "  run-all   - Run all implemented days"
	@echo "  check     - Check syntax without building"
	@echo "  clean     - Remove build artifacts"
	@echo "  help      - Show this message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run DAY=1"
	@echo "  make release"

.PHONY: all build release debug run run-all check clean help

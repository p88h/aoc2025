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
	./$(BUILD_DIR)/aoc2025

# Check code (syntax check without building)
check:
	$(ODIN) check $(SRC_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Build visualization executable
vis: | $(BUILD_DIR)
	$(ODIN) build vis -out:$(BUILD_DIR)/vis

# Build visualization with optimizations
vis-release: | $(BUILD_DIR)
	$(ODIN) build vis -out:$(BUILD_DIR)/vis -o:speed

# Run visualization (usage: make vis-run DAY=0)
vis-run: vis
	./$(BUILD_DIR)/vis $(DAY)

# Run visualization with recording
vis-rec: vis
	./$(BUILD_DIR)/vis rec $(DAY)

# Print help
help:
	@echo "Advent of Code 2025 - Odin Solutions"
	@echo ""
	@echo "Targets:"
	@echo "  build       - Build the project (default)"
	@echo "  release     - Build with optimizations"
	@echo "  debug       - Build with debug symbols"
	@echo "  run         - Run a specific day (DAY=N)"
	@echo "  run-all     - Run all implemented days"
	@echo "  check       - Check syntax without building"
	@echo "  clean       - Remove build artifacts"
	@echo "  vis         - Build visualization executable"
	@echo "  vis-release - Build visualization with optimizations"
	@echo "  vis-run     - Run visualization (DAY=N)"
	@echo "  vis-rec     - Run visualization with recording (DAY=N)"
	@echo "  help        - Show this message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run DAY=1"
	@echo "  make release"
	@echo "  make vis-run DAY=0"
	@echo "  make vis-rec DAY=0"

.PHONY: all build release debug run run-all check clean help vis vis-release vis-run vis-rec

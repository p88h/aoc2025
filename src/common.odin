package main

import "base:runtime"
import vmem "core:mem/virtual"

// Solution is the common interface that all day solutions implement.
// Each dayXX.odin should provide a dayXX() function that parses input
// and returns a Solution containing the parsed data and method implementations.
Solution :: struct {
	// Opaque pointer to day-specific parsed data
	data:  rawptr,

	// Method to solve part 1, returns the answer
	part1: proc(data: rawptr) -> int,

	// Method to solve part 2, returns the answer
	part2: proc(data: rawptr) -> int,
}

// Input is contents
DayRunner :: proc(contents: string) -> Solution

// testing support

G_TEST_ARENA: vmem.Arena

setup_test_allocator :: proc() -> proc() {
	context.allocator = vmem.arena_allocator(&G_TEST_ARENA)
	return proc() {
			free_all(context.allocator)
			context.allocator = runtime.default_allocator()
		}
}

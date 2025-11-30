package main

// Solution is the common interface that all day solutions implement.
// Each dayXX.odin should provide a dayXX() function that parses input
// and returns a Solution containing the parsed data and method implementations.
Solution :: struct {
    // Opaque pointer to day-specific parsed data
    data: rawptr,
    
    // Method to solve part 1, returns the answer
    part1: proc(data: rawptr) -> int,
    
    // Method to solve part 2, returns the answer  
    part2: proc(data: rawptr) -> int,
    
    // Optional cleanup procedure for freeing allocated data
    cleanup: proc(data: rawptr),
}

// DayRunner is the function signature for each day's entry point.
// It takes the input filename and returns a Solution ready to run.
DayRunner :: proc(contents: string) -> Solution

cleanup_raw_data :: proc(raw_data: rawptr) {
    if raw_data != nil {
        free(raw_data)
    }
}   
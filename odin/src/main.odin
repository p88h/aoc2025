package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import "day01"

// Available days
DAYS :: struct {
    day01: proc(string),
}

days := DAYS{
    day01 = day01.run,
}

main :: proc() {
    args := os.args
    
    if len(args) < 2 {
        print_usage()
        return
    }
    
    day_arg := args[1]
    
    // Parse day number
    day_num: int = ---
    if strings.has_prefix(day_arg, "day") {
        day_num, _ = strconv.parse_int(day_arg[3:])
    } else {
        day_num, _ = strconv.parse_int(day_arg)
    }
    
    // Determine input file
    input_file: string
    if len(args) >= 3 {
        input_file = args[2]
    } else {
        input_file = fmt.tprintf("inputs/day%02d.txt", day_num)
    }
    
    // Run the appropriate day
    switch day_num {
    case 1:
        days.day01(input_file)
    case:
        fmt.eprintln("Error: Day", day_num, "not implemented yet")
        print_usage()
    }
}

print_usage :: proc() {
    fmt.println("Advent of Code 2025 - Odin Solutions")
    fmt.println()
    fmt.println("Usage: aoc2025 <day> [input_file]")
    fmt.println()
    fmt.println("Arguments:")
    fmt.println("  day         Day number (1-25) or dayNN format")
    fmt.println("  input_file  Optional path to input file")
    fmt.println("              Default: inputs/dayNN.txt")
    fmt.println()
    fmt.println("Examples:")
    fmt.println("  aoc2025 1")
    fmt.println("  aoc2025 day01")
    fmt.println("  aoc2025 1 my_input.txt")
}

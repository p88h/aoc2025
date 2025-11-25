package day01

import "core:fmt"
import "../utils"

// Solve Part 1 of Day 01
solve_part1 :: proc(lines: []string) -> int {
    // TODO: Implement part 1 solution
    // This is a placeholder that counts lines
    return len(lines)
}

// Solve Part 2 of Day 01
solve_part2 :: proc(lines: []string) -> int {
    // TODO: Implement part 2 solution
    // This is a placeholder that sums line lengths
    total := 0
    for line in lines {
        total += len(line)
    }
    return total
}

// Run Day 01 solutions
run :: proc(input_file: string) {
    lines, ok := utils.read_lines(input_file)
    if !ok {
        fmt.eprintln("Error: Could not read input file:", input_file)
        return
    }
    
    fmt.println("Day 01:")
    fmt.println("  Part 1:", solve_part1(lines))
    fmt.println("  Part 2:", solve_part2(lines))
}

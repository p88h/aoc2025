package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

DAY_RUNNERS :: [?]DayRunner {
    day01, 
}

main :: proc() {
    args := os.args    
    day_num: int = 0
    if len(args) > 1 {
        stripped := strings.trim_left_proc(args[1], proc(r: rune) -> bool {
            return !('0' <= r && r <= '9')
        })
        day_num, _ = strconv.parse_int(stripped)
    }
      
    day_runners := DAY_RUNNERS
    // Validate day number and get runner
    if day_num < 0 || day_num > len(day_runners) {
        fmt.eprintln("Error: Day", day_num, "not implemented yet")
        return
    }

    // print result header
    fmt.printf("        parse   part1   part2   total\n")
    single := day_num != 0
    for d := 1; d <= len(day_runners); d += 1 {
        if day_num != 0 && day_num != d {
            continue
        }
        contents, ok := get_input(d)
        if !ok {
            fmt.eprintln("Error: Could not read input for day", d)
            continue
        }
        run_day(d, day_runners[d - 1], contents, single)
    }
}


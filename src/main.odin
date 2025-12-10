package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

DAY_RUNNERS :: [?]DayRunner{day01, day02, day03, day04, day05, day06, day07, day08, day09, day10}

main :: proc() {
	args := os.args
	day_num: int = 0
	debug := false
	threading := true
	for ap := 1; ap < len(args); ap += 1 {
		if args[ap] == "debug" {
			debug = true
			continue
		}
		if args[ap] == "single" {
			threading = false
			continue
		}
		stripped := strings.trim_left_proc(args[ap], proc(r: rune) -> bool {
			return !('0' <= r && r <= '9')
		})
		val, ok := strconv.parse_int(stripped)
		if ok {
			day_num = val
		}
	}

	day_runners := DAY_RUNNERS
	// Validate day number and get runner
	if day_num < 0 || day_num > len(day_runners) {
		fmt.eprintln("Error: Day", day_num, "not implemented yet")
		return
	}

	if debug && day_num != 0 {
		fmt.println("Running in debug mode")
		runner := day_runners[day_num - 1]
		contents, ok := get_input(day_num)
		if !ok {
			fmt.eprintln("Error: Could not read input for day", day_num)
			return
		}
		ctx := runner(contents)
		fmt.println("Part 1 result:", ctx.part1(ctx.data))
		fmt.println("Part 2 result:", ctx.part2(ctx.data))
		return
	}

	init_threads(threading)
	defer stop_threads()

	// print result header
	fmt.printf("        parse   part1   part2   total\n")
	single := day_num != 0
	total := u64(0)
	for d := 1; d <= len(day_runners); d += 1 {
		if day_num != 0 && day_num != d {
			continue
		}
		contents, ok := get_input(d)
		if !ok {
			fmt.eprintln("Error: Could not read input for day", d)
			continue
		}
		total += run_day(d, day_runners[d - 1], contents, single)
	}
	if (!single) {
		fmt.print("\nTotal time: ")
		print_time(total)
		fmt.println("")
	}
}

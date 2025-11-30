package main

// Boilerplate
Day01Data :: struct {
	lines: []string,
}

day01 :: proc(contents: string) -> Solution {
	data := new(Day01Data)
	data.lines = split_lines(contents)
	return Solution{data = data, part1 = day01_part1, part2 = day01_part2, cleanup = cleanup_raw_data}
}

day01_part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day01Data)raw_data
	return len(data.lines)
}

day01_part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day01Data)raw_data
	total := 0
	for line in data.lines {
		total += len(line)
	}
	return total
}

package main

import "core:testing"
Day0Data :: struct {
	lines: []string,
}

day00 :: proc(contents: string) -> Solution {
	data := new(Day0Data)
	data.lines = split_lines(contents)
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day0Data)raw_data
	return len(data.lines)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day0Data)raw_data
	ret := 0
	for line in data.lines {
		ret += len(line)
	}
	return ret
}

@(test)
test_day00 :: proc(t: ^testing.T) {
	input := "ABC\nDEF\nGH\nIJ\nB\nA\n"
	defer setup_test_allocator()()
	solution := day00(input)
	testing.expect_value(t, solution.part1(solution.data), 6)
	testing.expect_value(t, solution.part2(solution.data), 12)
}

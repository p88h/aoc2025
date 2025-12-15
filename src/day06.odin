package main

import "core:testing"

Day6Data :: struct {
	ops:   [dynamic]byte,
	pos:   [dynamic]int,
	lines: []string,
}

day06 :: proc(contents: string) -> Solution {
	data := new(Day6Data)
	data.lines = split_lines(contents)
	last := data.lines[len(data.lines) - 1]
	data.pos = make([dynamic]int)
	for i in 0 ..< len(last) {
		if last[i] != ' ' {
			append(&data.ops, last[i])
			append(&data.pos, i)
		}
	}
	append(&data.pos, len(last))
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day6Data)raw_data
	height := len(data.lines) - 1
	total := 0
	for i in 0 ..< len(data.ops) {
		op := data.ops[i]
		result := 1 if op == '*' else 0
		start := data.pos[i]
		end := data.pos[i + 1]
		if i < len(data.ops) - 1 {
			end -= 1
		}
		for j in 0 ..< height {
			num := 0
			for k in start ..< end {
				ch := data.lines[j][k]
				if ch != ' ' {
					num = num * 10 + int(ch - '0')
				}
			}
			result = result * num if op == '*' else result + num
		}
		total += result
	}
	return total
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day6Data)raw_data
	height := len(data.lines) - 1
	total := 0
	for i in 0 ..< len(data.ops) {
		op := data.ops[i]
		result := 1 if op == '*' else 0
		start := data.pos[i]
		end := data.pos[i + 1]
		if i < len(data.ops) - 1 {
			end -= 1
		}
		for k in start ..< end {
			num := 0
			for j in 0 ..< height {
				ch := data.lines[j][k]
				if ch != ' ' {
					num = num * 10 + int(ch - '0')
				}
			}
			result = result * num if op == '*' else result + num
		}
		total += result
	}
	return total
}

@(test)
test_day06 :: proc(t: ^testing.T) {
	input := "123 328  51 64 \n" + " 45 64  387 23 \n" + "  6 98  215 314\n" + "*   +   *   +  "
	defer setup_test_allocator()()
	solution := day06(input)
	// testing.expect_value(t, solution.part1(solution.data), 4277556)
	testing.expect_value(t, solution.part2(solution.data), 3263827)
}

package main

import "core:testing"
MAX_WIDTH :: 100
MAX_ITER :: 16

Day3Input :: struct {
	next:  [][MAX_WIDTH]u64,
	width: int,
}

day03 :: proc(contents: string) -> Solution {
	data := new(Day3Input)
	lines := split_lines(contents)
	// lowest position of each digit 1-9 at each position
	data.next = make([][MAX_WIDTH]u64, len(lines))
	data.width = len(lines[0])
	width := data.width
	for i in 0 ..< len(lines) {
		tmp_next: u64 = 0xFFFFFFFFFFFFFFFF
		for j in 0 ..< width {
			v := uint(lines[i][width - j - 1] - '0')
			// clear out 7 bits for this digit
			tmp_next &= ~(u64(0x7F) << ((v - 1) * 7))
			tmp_next |= u64(width - j - 1) << ((v - 1) * 7)
			data.next[i][width - j - 1] = tmp_next
		}
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
solve3 :: proc(data: ^Day3Input, $iter: int) -> int {
	tot := 0
	// use locals
	width := data.width
	for i in 0 ..< len(data.next) {
		sol := 0
		pos := 0
		for k in 0 ..< iter {
			// find next best digit to use
			for d in 1 ..< 10 {
				rd := (10 - d)
				d_pos := cast(int)(data.next[i][pos] >> (cast(uint)(rd - 1) * 7) & 0x7F)
				if d_pos + (iter - k - 1) < width {
					sol = sol * 10 + rd
					pos = d_pos + 1
					break
				}
			}
		}
		tot += sol
	}
	return tot
}


@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	return solve3(cast(^Day3Input)raw_data, 2)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	return solve3(cast(^Day3Input)raw_data, 12)
}

@(test)
test_day03 :: proc(t: ^testing.T) {
	input := "987654321111111\n" + "811111111111119\n" + "234234234234278\n" + "818181911112111\n"
	defer setup_test_allocator()()
	solution := day03(input)
	testing.expect_value(t, solution.part1(solution.data), 357)
	testing.expect_value(t, solution.part2(solution.data), 3121910778619)
}

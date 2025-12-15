package main

import "core:strings"
import "core:testing"
Day7Data :: struct {
	pos:   int,
	grid:  []byte,
	width: int,
	beams: []int,
}

day07 :: proc(contents: string) -> Solution {
	data := new(Day7Data)
	width := strings.index(contents, "\n") + 1
	data.pos = strings.index(contents, "S")
	data.grid = transmute([]byte)contents
	data.width = width
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day7Data)raw_data
	width := data.width
	beams := make([]int, width)
	splits := 0
	beams[data.pos] = 1
	start := data.pos
	end := data.pos + 1
	for ofs := width * 2; ofs < len(data.grid); ofs += width * 2 {
		for i in start ..< end do if beams[i] > 0 && data.grid[ofs + i] == '^' {
			beams[i - 1] += beams[i]
			beams[i + 1] += beams[i]
			beams[i] = 0
			splits += 1
		}
		start -= 1
		end += 1
	}
	data.beams = beams
	return splits
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day7Data)raw_data
	ret := 0
	for b in data.beams {
		ret += b
	}
	return ret
}

@(test)
test_day07 :: proc(t: ^testing.T) {
	input :=
		".......S.......\n" +
		"...............\n" +
		".......^.......\n" +
		"...............\n" +
		"......^.^......\n" +
		"...............\n" +
		".....^.^.^.....\n" +
		"...............\n" +
		"....^.^...^....\n" +
		"...............\n" +
		"...^.^...^.^...\n" +
		"...............\n" +
		"..^...^.....^..\n" +
		"...............\n" +
		".^.^.^.^.^...^.\n" +
		"..............."
	defer setup_test_allocator()()
	solution := day07(input)
	testing.expect_value(t, solution.part1(solution.data), 21)
	testing.expect_value(t, solution.part2(solution.data), 40)
}

package main

import "core:strings"
import "core:testing"
Day7Data :: struct {
	pos: int,
	grid: []byte,
    width: int,
}

day07 :: proc(contents: string) -> Solution {
	data := new(Day7Data)
    width := strings.index(contents, "\n") + 1
	data.pos = strings.index(contents, "S");
    // copy the contents to a grid(byte array), where ^ maps to 2 and . maps to 1
    data.grid = make([]byte, len(contents))
    for i in 0 ..< len(data.grid) do data.grid[i] = byte(contents[i]) / 45
    data.width = width
	return Solution{data = data, part1 = part1, part2 = part2}
}


@(private = "file")
compute_beams :: #force_inline proc(data: ^Day7Data, $check: bool) -> (int, []int) {
    width := data.width
	beams := make([]int, width)
	next_beams := make([]int, width)
	splits := 0
    beams[data.pos] = 1
	for ofs:= 0; ofs < len(data.grid); ofs += width {
        line := data.grid[ofs:ofs+width]
		for i in 0 ..< width do next_beams[i] = beams[i] * int(line[i] & 1)
		for i in 1 ..< width - 1 {
            lr := int(line[i] >> 1)
            next_beams[i-1] += beams[i] * lr 
            next_beams[i+1] += beams[i] * lr 
            if check && beams[i] > 0 { splits += lr }
        }
		for i in 0 ..< width do beams[i] = next_beams[i]
	}
	return splits, beams
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	splits, _ := compute_beams(cast(^Day7Data)raw_data, true)
	return splits
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	_, beams := compute_beams(cast(^Day7Data)raw_data, false)
	ret := 0
	for b in beams {
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

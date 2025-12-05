package main

import "core:strings"
import "core:testing"

Day4Input :: struct {
	grid:   [160][160]i8,
	width:  int,
	height: int,
}

day04 :: proc(contents: string) -> Solution {
	data := new(Day4Input)
	width := strings.index(contents, "\n")
	height := len(contents) / (width + 1)
	hgrid := [160][160]i8{}
	for i in 1 ..= height {
		for j in 1 ..= width {
			ch := contents[(i - 1) * (width + 1) + (j - 1)]
			if ch == '@' {
				hgrid[i][j - 1] += 1
				hgrid[i][j] += 1
				hgrid[i][j + 1] += 1
			}
		}
	}
	// border
	for j in 0 ..< width + 2 {
		data.grid[0][j] = -1
		data.grid[height + 1][j] = -1
	}
	for i in 1 ..= height {
		data.grid[i][0] = -1
		data.grid[i][width + 1] = -1
		for j in 1 ..= width {
			ch := contents[(i - 1) * (width + 1) + (j - 1)]
			if ch != '@' {
				data.grid[i][j] = -1
			} else {
				data.grid[i][j] = hgrid[i - 1][j] + hgrid[i][j] + hgrid[i + 1][j] - 1
			}
		}
		// fmt.println(data.grid[i][1:width+1])
	}
	data.width = width
	data.height = height
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day4Input)raw_data
	total := 0
	for row in 1 ..= data.height {
		for col in 1 ..= data.width {
			if data.grid[row][col] >= 0 && data.grid[row][col] < 4 {
				total += 1
			}
		}
	}
	return total
}

// extracted for visualization
day4_find_start_pos :: proc(data: ^Day4Input) -> [dynamic]int {
	positions := make([dynamic]int)
	for row in 1 ..= data.height {
		for col in 1 ..= data.width {
			if data.grid[row][col] >= 0 && data.grid[row][col] < 4 {
				append(&positions, row << 8 + col)
			}
		}
	}
	return positions
}

day4_remove_cell :: proc(data: ^Day4Input, pos: ^[dynamic]int, row: int, col: int) {
	// remove this block, decrease counters in all neighboring positions
	data.grid[row][col] = -1
	for dr in -1 ..< 2 {
		for dc in -1 ..< 2 {
			nrow := row + dr
			ncol := col + dc
			data.grid[nrow][ncol] -= 1
			if data.grid[nrow][ncol] == 3 {
				new_pos := nrow << 8 + ncol
				append(pos, new_pos)
			}
		}
	}
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day4Input)raw_data
	pos := day4_find_start_pos(data)
	idx := 0
	for len(pos) > 0 {
		val := pop(&pos)
		day4_remove_cell(data, &pos, val >> 8, val & 0xFF)
		idx += 1
	}
	return idx
}

@(test)
test_day04 :: proc(t: ^testing.T) {
	input :=
		"..@@.@@@@.\n" +
		"@@@.@.@.@@\n" +
		"@@@@@.@.@@\n" +
		"@.@@@@..@.\n" +
		"@@.@@@@.@@\n" +
		".@@@@@@@.@\n" +
		".@.@.@.@@@\n" +
		"@.@@@.@@@@\n" +
		".@@@@@@@@.\n" +
		"@.@.@@@.@.\n"
	defer setup_test_allocator()()
	solution := day04(input)
	testing.expect_value(t, solution.part1(solution.data), 13)
	testing.expect_value(t, solution.part2(solution.data), 43)
}

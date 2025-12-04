package main

import "core:strings"
import "core:fmt"

@(private = "file")
ParsedInput :: struct {
	grid: [160][160]i8,
    width: int,
    height: int,
}

day04 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
	hgrid := [160][160]i8{}
    width := len(lines[0])
    height := len(lines)
	for i in 1 ..= height {
        for j in 1 ..= width {
            ch := lines[i-1][j-1]
            if ch == '@' {
                hgrid[i][j-1] += 1
                hgrid[i][j] += 1
                hgrid[i][j+1] += 1
            }
        }
	}
    // border
    for j in 0 ..< width+2 {
        data.grid[0][j] = -1
        data.grid[height+1][j] = -1
    }
	for i in 1 ..= height {
        data.grid[i][0] = -1
        data.grid[i][width+1] = -1
        for j in 1 ..= width {
            ch := lines[i-1][j-1]
            if ch != '@' {
                data.grid[i][j] = -1
            } else {
                data.grid[i][j] = hgrid[i-1][j] + hgrid[i][j] + hgrid[i+1][j] - 1;
            }
        }
        // fmt.println(data.grid[i][1:width+1])
    }
    data.width = width
    data.height = height
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

find_start_pos :: proc(data: ^ParsedInput) -> [dynamic]int {
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

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^ParsedInput)raw_data
	total := len(find_start_pos(data))
	return total
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^ParsedInput)raw_data
    pos := find_start_pos(data)
    idx := 0
    for idx < len(pos) {
        p := pos[idx]
        idx += 1
        row := p >> 8
        col := p & 0xFF
        val := data.grid[row][col]
        // remove this block, decrease counters in all neighboring positions
        data.grid[row][col] = -1
        for dr in -1..<2 {
            for dc in -1..<2 {
                nrow := row + dr
                ncol := col + dc
                data.grid[nrow][ncol] -= 1
                if data.grid[nrow][ncol] == 3 {
                    new_pos := nrow << 8 + ncol
                    append(&pos, new_pos)
                }
            }
        }
    }
	return len(pos)
}

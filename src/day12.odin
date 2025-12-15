package main

import "core:testing"

Day12Data :: struct {
	blocks:  [dynamic]Block,
	regions: [dynamic]Region,
}

Block :: struct {
	id:    int,
	tiles: int,
	grid:  [3][3]bool,
}

Region :: struct {
	width:  int,
	height: int,
	counts: []int,
}

rotate_block :: proc(b: Block) -> Block {
	new_block := Block {
		id = b.id,
	}
	for i in 0 ..< 3 {
		for j in 0 ..< 3 {
			new_block.grid[j][2 - i] = b.grid[i][j]
		}
	}
	return new_block
}

flip_block :: proc(b: Block) -> Block {
	new_block := Block {
		id = b.id,
	}
	for i in 0 ..< 3 {
		for j in 0 ..< 3 {
			new_block.grid[i][2 - j] = b.grid[i][j]
		}
	}
	return new_block
}

day12 :: proc(contents: string) -> Solution {
	data := new(Day12Data)
	lines := split_lines(contents)
	i := 0
	for i < len(lines) {
		// new 3x3 block follows
		if lines[i][len(lines[i]) - 1] == ':' {
			block := Block {
				id = len(data.blocks),
			}
			for bi in 0 ..< 3 {
				for bj in 0 ..< 3 {
					block.grid[bi][bj] = lines[i + 1 + bi][bj] == '#'
					if block.grid[bi][bj] do block.tiles += 1
				}
			}
			append(&data.blocks, block)
			// skip 3 block lines + empty line
			i += 4
		} else {
			nums := fast_parse_all_integers(lines[i])
			reg := Region {
				width  = nums[0],
				height = nums[1],
				counts = nums[3:],
			}
			append(&data.regions, reg)
		}
		// next line
		i += 1
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day12Data)raw_data
	ans := 0
	for reg in data.regions {
		total_tiles := 0
		for bid in 0 ..< len(data.blocks) {
			block := data.blocks[cast(int)bid]
			total_tiles += block.tiles * reg.counts[cast(int)bid]
		}
		if total_tiles <= reg.width * reg.height {
			ans += 1
		}
	}
	return ans
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day12Data)raw_data
	ret := 0
	return ret
}

package main

import "core:simd"

MAX_WIDTH :: 100
MAX_ITER :: 16
SIMD_TYPE :: simd.u64x8
SIMD_WIDTH :: 8

@(private = "file")
ParsedInput :: struct {
	num_simd: [][MAX_WIDTH]SIMD_TYPE,
	width:    int,
}

day03 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
	data.num_simd = make([][MAX_WIDTH]SIMD_TYPE, len(lines) / SIMD_WIDTH)
	data.width = len(lines[0])
	for i in 0 ..< len(lines) / SIMD_WIDTH {
		for j in 0 ..< data.width {
			data.num_simd[i][j] = SIMD_TYPE {
				u64(lines[i * 4][j] - '0'),
				u64(lines[i * 4 + 1][j] - '0'),
				u64(lines[i * 4 + 2][j] - '0'),
				u64(lines[i * 4 + 3][j] - '0'),
				u64(lines[i * 4 + 4][j] - '0'),
				u64(lines[i * 4 + 5][j] - '0'),
				u64(lines[i * 4 + 6][j] - '0'),
				u64(lines[i * 4 + 7][j] - '0'),
			}
		}
	}
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
solve :: proc(data: ^ParsedInput, $iter: int) -> int {
	tot := 0
	// use locals
	width := data.width
	x10 := SIMD_TYPE{10, 10, 10, 10, 10, 10, 10, 10}
	max_simd: [MAX_ITER]SIMD_TYPE = {}
	for i in 0 ..< len(data.num_simd) {
		// best sequence of each length up to current position
		max_simd = SIMD_TYPE{0, 0, 0, 0, 0, 0, 0, 0}
		for j in 0 ..< width {
			num_simd := data.num_simd[i][j]
			// try to extend each best, from the longest
			#unroll for k in 0 ..< iter {
				next_simd := simd.add(simd.mul(max_simd[iter - k - 1], x10), num_simd)
				// check if this improves this legnth
				max_simd[iter - k] = simd.max(max_simd[iter - k], next_simd)
			}
		}
		tot += cast(int)simd.reduce_add_bisect(max_simd[iter])
	}
	return tot
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	return solve(cast(^ParsedInput)raw_data, 2)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	return solve(cast(^ParsedInput)raw_data, 12)
}

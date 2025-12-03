package main

import "core:simd"

@(private = "file")
ParsedInput :: struct {
	lines: [][]int,
}

day03 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
	data.lines = make([][]int, len(lines))
	for line, idx in lines {
		data.lines[idx] = make([]int, len(line))
		for cidx in 0 ..< len(line) {
			data.lines[idx][cidx] = int(line[cidx] - '0')
		}
	}
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^ParsedInput)raw_data
	tot := 0
	for line in data.lines {
		pmax := 0
		max := 0
		for v in line {
			if pmax * 10 + v > max {
				max = pmax * 10 + v
			}
			if v > pmax {
				pmax = v
			}
		}
		tot += max
		// Placeholder logic for part 1
	}
	return tot
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^ParsedInput)raw_data
	tot := 0
	num_simd := make([]simd.u64x4, len(data.lines[0]))
	max_simd := make([]simd.u64x4, len(data.lines[0]))
	for i in 0 ..< len(data.lines) / 4 {
		for j in 0 ..< len(data.lines[0]) {
			num_simd[j] = simd.from_array(
				[4]u64 {
					u64(data.lines[i * 4][j]),
					u64(data.lines[i * 4 + 1][j]),
					u64(data.lines[i * 4 + 2][j]),
					u64(data.lines[i * 4 + 3][j]),
				},
			)
			max_simd[j] = num_simd[j]
		}
		row_max := simd.u64x4{0, 0, 0, 0}
		for _ in 1 ..< 12 {
			pmax_simd := simd.u64x4{0, 0, 0, 0}
			for j in 0 ..< len(data.lines[0]) {
				next_simd := simd.add(simd.mul(pmax_simd, simd.u64x4{10, 10, 10, 10}), num_simd[j])
				// update pmax for the next position
				pmax_simd = simd.max(pmax_simd, max_simd[j])
				// update num_simd[j] for the next iteration
				max_simd[j] = next_simd
				row_max = simd.max(row_max, next_simd)
			}
		}
		tot += cast(int)simd.reduce_add_bisect(row_max)
	}
	return tot
}

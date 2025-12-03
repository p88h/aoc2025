package main

MAX_WIDTH :: 100
MAX_ITER :: 16

@(private = "file")
ParsedInput :: struct {
	nums:  [][MAX_WIDTH]int,
	start: []int,
	width: int,
}

day03 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
	data.nums = make([][MAX_WIDTH]int, len(lines))
	data.start = make([]int, len(lines))
	data.width = len(lines[0])
	max_start := data.width - MAX_ITER
	for i in 0 ..< len(lines) {
		best := 0
		for j in 0 ..< data.width {
			v := int(lines[i][j] - '0')
			data.nums[i][j] = v
			if v > best && j <= max_start {
				best = v
				data.start[i] = j
			}
		}
	}
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
solve2 :: proc(data: ^ParsedInput, $iter: int) -> int {
	tot := 0
	// use locals
	width := data.width
	// best sequence of each length up to current position
	max_seq: [MAX_ITER]int = {}
	for i in 0 ..< len(data.nums) {
		max_seq = 0
		for j in data.start[i] ..< width {
			num := data.nums[i][j]
			// try to extend each best, from the longest
			#unroll for k in 0 ..< iter {
				next_seq := max_seq[iter - k - 1] * 10 + num
				// check if it improves this length
				max_seq[iter - k] = max(max_seq[iter - k], next_seq)
			}
		}
		tot += max_seq[iter]
	}
	return tot
}
@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	return solve2(cast(^ParsedInput)raw_data, 2)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	return solve2(cast(^ParsedInput)raw_data, 12)
}

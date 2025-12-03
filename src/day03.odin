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
solve3 :: proc(data: ^ParsedInput, $iter: int) -> int {
	tot := 0
	// use locals
	width := data.width
	// lowest index for each digit to continue from
	best_next : [MAX_WIDTH]u64 = {}
	for i in 0 ..< len(data.nums) {
		tmp_next : u64 = 0xFFFFFFFFFFFFFFFF
		// go backwards to fill best_next digit positions		
		for j in 0 ..< width-data.start[i] {
			num : uint = cast(uint)data.nums[i][width - j - 1]
			// clear out 7 bits for this digit
			tmp_next &= ~(u64(0x7F) << ((num-1) * 7))
			tmp_next |= u64(width - j - 1) << ((num-1) * 7)
			best_next[width - j - 1] = tmp_next
		}
		sol := 0
		pos := data.start[i]
		for k in 0..<iter {
			// find next best digit to use
			for d in 1 ..< 10 {
				rd := (10 - d)
				d_pos := cast(int)(best_next[pos] >> (cast(uint)(rd-1) * 7) & 0x7F)
				if d_pos + (iter - k - 1) < width {
					sol = sol * 10 + rd
					pos = d_pos + 1
					break;
				}
			} 
		}
		tot += sol
	}
	return tot
}


@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	return solve3(cast(^ParsedInput)raw_data, 2)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	return solve3(cast(^ParsedInput)raw_data, 12)
}

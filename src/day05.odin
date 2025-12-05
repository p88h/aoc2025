package main

import "core:slice"

@(private = "file")
Range :: struct {
	start: int,
	end:   int,
}

Day5Input :: struct {
	ranges:  [dynamic]Range,
	samples: []int,
}

day05 :: proc(contents: string) -> Solution {
	data := new(Day5Input)
	nums := fast_parse_all_integers(contents)
	ofs := 0
	for nums[ofs] != 0 {
		ofs += 2
	}
	tmp_ranges := make([]Range, ofs / 2)
	data.samples = make([]int, len(nums) - ofs - 1)
	for idx in 0 ..< ofs / 2 {
		start := nums[idx * 2]
		end := nums[idx * 2 + 1]
		tmp_ranges[idx] = Range {
			start = start,
			end   = end,
		}
	}
	// preprocess: sort ranges by start point
	slice.sort_by(tmp_ranges, proc(a, b: Range) -> bool {
		return a.start < b.start
	})
	// Merge overlapping ranges
	data.ranges = make([dynamic]Range)
	current := tmp_ranges[0]
	for i in 1 ..< len(tmp_ranges) {
		r := tmp_ranges[i]
		if r.start <= current.end + 1 {
			if r.end > current.end {
				current.end = r.end
			}
		} else {
			append(&data.ranges, current)
			current = r
		}
	}
	append(&data.ranges, current)
	for idx in ofs + 1 ..< len(nums) {
		data.samples[idx - ofs - 1] = nums[idx]
	}
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}


@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day5Input)raw_data
	ret := 0
	for s in data.samples {
		// Binary search for the insertion point
		idx, found := slice.binary_search_by(data.ranges[:], s, proc(r: Range, key: int) -> slice.Ordering {
			if r.start < key do return .Less
			if r.start > key do return .Greater
			return .Equal
		})
		if !found && idx > 0 {
			idx -= 1
		}
		if idx < len(data.ranges) && data.ranges[idx].start <= s && s <= data.ranges[idx].end {
			ret += 1
		}
	}
	return ret
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day5Input)raw_data
	ret := 0
	for s in data.ranges {
		ret = ret + (s.end - s.start + 1)
	}
	return ret
}

package main

import "core:slice"
import "core:testing"

@(private = "file")
Range :: struct {
	start: u64,
	end:   u64,
}

Day5Input :: struct {
	ranges:  [dynamic]Range,
	samples: []u64,
}

day05 :: proc(contents: string) -> Solution {
	data := new(Day5Input)
	nums := fast_parse_all_integers(contents)
	ofs := 0
	for nums[ofs] != 0 {
		ofs += 2
	}
	tmp_ranges := make([]Range, ofs / 2)
	data.samples = make([]u64, len(nums) - ofs - 1)
	for idx in 0 ..< ofs / 2 {
		start := nums[idx * 2]
		end := nums[idx * 2 + 1]
		tmp_ranges[idx] = Range {
			start = u64(start),
			end   = u64(end),
		}
	}
	radix_sort(tmp_ranges, size_of(u64))
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
		data.samples[idx - ofs - 1] = u64(nums[idx])
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}


@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day5Input)raw_data
	ret := 0
	for s in data.samples {
		// Binary search for the insertion point
		idx, found := slice.binary_search_by(data.ranges[:], s, proc(r: Range, key: u64) -> slice.Ordering {
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
	ret: u64 = 0
	for s in data.ranges {
		ret = ret + (s.end - s.start + 1)
	}
	return int(ret)
}

@(test)
test_day05 :: proc(t: ^testing.T) {
	input := "3-5\n10-14\n16-20\n12-18\n\n" + "1\n5\n8\n11\n17\n32"
	defer setup_test_allocator()()
	solution := day05(input)
	testing.expect_value(t, solution.part1(solution.data), 3)
	testing.expect_value(t, solution.part2(solution.data), 14)
}

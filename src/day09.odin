package main

import "core:testing"
Day9Data :: struct {
	nums: [dynamic]int,
	len:  int,
    pos: int
}

day09 :: proc(contents: string) -> Solution {
	data := new(Day9Data)
	data.nums = fast_parse_all_integers(contents)
	data.len = len(data.nums) / 2
    maxdx:= 0
    // find the special points
    for i in 1..<data.len {
        dx := abs(data.nums[i*2] - data.nums[(i-1)*2])
        if dx > maxdx {
            maxdx = dx
            data.pos = i
        }
    }
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day9Data)raw_data
	ret := 0
    BEAM :: 8
	for i in 0 ..< data.len/2 {
		x1, y1 := data.nums[i * 2], data.nums[i * 2 + 1]
		for k in 0 ..< BEAM {
            j := ((i + data.len / 2) + (k - BEAM / 2)) % data.len
			x2, y2 := data.nums[j * 2], data.nums[j * 2 + 1]
			area := (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
			ret = max(ret, area)
		}
	}
	return ret
}

day9_scan_from :: proc(data: ^Day9Data, i: int, kdir: int, limit: int) -> (int,int) {
	limit := limit
	j := i
	k := 0 if kdir > 0 else data.len - 1
	maxx := 0
	x1, y1 := data.nums[i * 2], data.nums[i * 2 + 1]
	ret := 0
	best := i
	for {
		limit -= 1
		if limit < 0 do break
		j -= kdir
		x2, y2 := data.nums[j * 2], data.nums[j * 2 + 1]
		if x2 < maxx do continue
		maxx = x2
		// find corresponding point
		for data.nums[k * 2 + 1] * kdir < y2 * kdir {
			k += kdir
		}
		if data.nums[k * 2] < x1 do break
		area := (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
		if area > ret {
			ret = area
			best = j
		}
	}
	return ret,best
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day9Data)raw_data
    // 248 & 249 are the indexes of the two points inside the circle
    // ... could probably be found programmatically ?
	ret1,_ := day9_scan_from(data, data.pos, 1, 100)
	ret2,_ := day9_scan_from(data, data.pos + 1, -1, 100)
	return max(ret1, ret2)
}

@(test)
test_day09 :: proc(t: ^testing.T) {
	input := "7,1\n11,1\n11,7\n9,7\n9,5\n2,5\n2,3\n7,3"
	defer setup_test_allocator()()
	solution := day09(input)
	testing.expect_value(t, solution.part1(solution.data), 50)
	// part2 approach will not work with test data
}

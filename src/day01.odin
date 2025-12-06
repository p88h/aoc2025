package main

import "core:testing"

Day1Data :: struct {
	nums: [dynamic]int,
}

day01 :: proc(contents: string) -> Solution {
	data := new(Day1Data)
	buf := transmute([]byte)contents
	data.nums = make([dynamic]int)
	sign := 1
	value := 0
	for c in buf do switch c {
	case 'L':
		sign = -1
	case 'R':
		sign = 1
	case '0' ..= '9':
		value = value * 10 + cast(int)(c - '0')
	case '\n':
		append(&data.nums, sign * value)
		value = 0
		sign = 1
	}
	if (value) != 0 {
		append(&data.nums, sign * value)
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day1Data)raw_data
	pos := 50
	pass := 0
	for num in data.nums {
		ofs := num
		pos = (pos + num) % 100
		if pos == 0 {
			pass += 1
		}
	}
	return pass
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day1Data)raw_data
	pos := 50
	pass := 0
	for num in data.nums {
		pass += abs(num) / 100
		amt := num % 100
		if (pos > 0 && pos + amt <= 0) || pos + amt >= 100 {
			pass += 1
		}
		pos = (pos + 100 + amt) % 100
	}
	return pass
}

@(test)
test_day01 :: proc(t: ^testing.T) {
	input := "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82"
	defer setup_test_allocator()()
	solution := day01(input)
	testing.expect_value(t, solution.part1(solution.data), 3)
	testing.expect_value(t, solution.part2(solution.data), 5)
}

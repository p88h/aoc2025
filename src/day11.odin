package main

import "core:fmt"
import "core:strings"
import "core:testing"
Day11Data :: struct {
	graph: [1024][dynamic]i16,
	paths: [1024]int,
	codes: [18000]i16,
	size: int,
}

day11 :: proc(contents: string) -> Solution {
	data := new(Day11Data)
	id := 0
	l := 0
	current := 0
	for c in contents do switch c {
	case 'a' ..= 'z':
		id = id * 26 + (int(c) - int('a'))
		l += 1
	case ':':
		// assign code if needed
		if data.codes[id] == 0 {
			data.size += 1
			data.codes[id] = i16(data.size)
		}
		current = int(data.codes[id])
		id = 0
		l = 0
	case '\n', ' ':
		if l == 0 do continue
		// assign code if needed
		if data.codes[id] == 0 {
			data.size += 1
			data.codes[id] = i16(data.size)
		}
		append(&data.graph[current], data.codes[id])
		id = 0
		l = 0
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
search :: proc(data: ^Day11Data, node: i16, target: i16) -> int {
	if data.paths[node] != 0 {
		return data.paths[node] - 1
	}
	if node == target {
		return 1
	}
	count := 0
	for neighbor in data.graph[node] {
		count += search(data, neighbor, target)
	}
	data.paths[node] = count + 1
	return count
}

@(private = "file")
encode :: proc(s: string) -> int {
	id := 0
	for c in s do id = id * 26 + (int(c) - int('a'))
	return id
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day11Data)raw_data
	return search(data, data.codes[encode("you")], data.codes[encode("out")])
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day11Data)raw_data
	svr := data.codes[encode("svr")]
	fft := data.codes[encode("fft")]
	dac := data.codes[encode("dac")]
	out := data.codes[encode("out")]
	for key in 0 ..< 1024 do data.paths[key] = 0
	ret2 := search(data, fft, dac)
	// swap if no paths found
	if (ret2 == 0) {
		fft, dac = dac, fft
		for key in 0 ..< 1024 do data.paths[key] = 0
		ret2 = search(data, fft, dac)
	}
	for key in 0 ..< 1024 do data.paths[key] = 0
	ret1 := search(data, svr, fft)
	for key in 0 ..< 1024 do data.paths[key] = 0
	ret3 := search(data, dac, out)
	return ret1 * ret2 * ret3
}

@(test)
test_day11_part1 :: proc(t: ^testing.T) {
	input :=
		"aaa: you hhh\n" +
		"you: bbb ccc\n" +
		"bbb: ddd eee\n" +
		"ccc: ddd eee fff\n" +
		"ddd: ggg\n" +
		"eee: out\n" +
		"fff: out\n" +
		"ggg: out\n" +
		"hhh: ccc fff iii\n" +
		"iii: out"
	defer setup_test_allocator()()
	solution := day11(input)
	testing.expect_value(t, solution.part1(solution.data), 5)
}

@(test)
test_day11_part2 :: proc(t: ^testing.T) {
	input :=
		"svr: aaa bbb\n" +
		"aaa: fft\n" +
		"fft: ccc\n" +
		"bbb: tty\n" +
		"tty: ccc\n" +
		"ccc: ddd eee\n" +
		"ddd: hub\n" +
		"hub: fff\n" +
		"eee: dac\n" +
		"dac: fff\n" +
		"fff: ggg hhh\n" +
		"ggg: out\n" +
		"hhh: out\n"
	defer setup_test_allocator()()
	solution := day11(input)
	testing.expect_value(t, solution.part2(solution.data), 2)
}

package main

import "core:testing"
Day11Data :: struct {
	graph: [1024][dynamic]i16,
	paths: [1024]int,
	codes: [18000]i16,
	size:  int,
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
SearchData :: struct {
	counters: [1024]int,
	stack:    [1024]i16,
	cnt:      int,
	dac:      i16,
	fft:      i16,
}

@(private = "file")
expand_node :: #force_inline proc(data: ^Day11Data, search: ^SearchData, node: i16) -> i16 {
	special := i16(0)
	for neighbor in data.graph[node] {
		search.counters[neighbor] -= 1
		data.paths[neighbor] += data.paths[node]
		if search.counters[neighbor] == 0 {
			search.stack[search.cnt] = neighbor
			search.cnt += 1
			if neighbor == search.dac || neighbor == search.fft do special = neighbor
		}
	}
	return special
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day11Data)raw_data
	search := SearchData {
		dac = data.codes[encode("dac")],
		fft = data.codes[encode("fft")],
	}
	svr := data.codes[encode("svr")]
	out := data.codes[encode("out")]

	for node in 0 ..= data.size {
		data.paths[node] = 0
		for next in data.graph[node] do search.counters[next] += 1
	}
	idx := 0
	search.cnt = 1
	search.stack[0] = svr
	data.paths[svr] = 1
	// Use stack based BFS so we can trim layers at special points
	// each step, exhaust edges from the 'current layer' of the stack
	// and add new nodes to the end of the stack, forming the next layer	
	for idx < search.cnt {
		limit := search.cnt
		special := i16(0)
		for i in idx ..< limit do special += expand_node(data, &search, search.stack[i])
		// If the layer contains a special node, exhaustively trim all other nodes in the layer
		if special != 0 {
			for search.cnt > limit {
				node := search.stack[search.cnt - 1]
				search.cnt -= 1
				if node == special do continue
				data.paths[node] = 0
				expand_node(data, &search, node)
			}
			// put special node back to the end of the stack
			search.stack[limit] = special
			search.cnt = limit + 1
		}
		idx = limit
	}
	return data.paths[out]
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

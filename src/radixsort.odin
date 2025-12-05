package main

import "core:testing"

// Implements basic sort for (mostly) arbitrary usigned-keyed data using LSD radix sort
radix_sort :: proc(data: $T/[]$E, $limit: int) {
	nel := len(data)
	raw := ([^]byte)(raw_data(data))
	_radix_sort(raw, nel, limit, size_of(E))
}

_radix_sort :: proc(base: [^]byte, nel: int, $limit: int, $width: int) {
	index := make([]u32, 256)
	defer delete(index)
	order := make([]u32, nel)
	defer delete(order)
	sorted := make([]u32, nel)
	defer delete(sorted)
	for i in 0 ..< nel {
		order[i] = u32(i)
	}
	// for each iteration (byte position)
	for iter in 1 ..= limit {
		ofs := iter - 1 // Process bytes from LSB to MSB (little-endian)
		// clear index counts
		for i in 0 ..< 256 {
			index[i] = 0
		}
		// count occurrences
		for i in 0 ..< nel {
			byte_value := base[int(order[i]) * width + ofs]
			index[byte_value] += 1
		}
		// compute first positions for each byte value based on counts
		sum := u32(0)
		for i in 0 ..< 256 {
			cnt := index[i]
			index[i] = sum
			sum += cnt
		}
		// rearrange order into sorted based on the index
		for i in 0 ..< nel {
			byte_value := base[int(order[i]) * width + ofs]
			pos := index[byte_value]
			index[byte_value] += 1
			sorted[pos] = order[i]
		}
		// replace order with sorted
		for i in 0 ..< nel {
			order[i] = sorted[i]
		}
	}
	// now rearrange the original data based on final order using the computed permutation
	for i in 0 ..< nel {
		if order[i] == u32(i) do continue

		// Start of a permutation cycle
		tmp_ptr := cast(^[width]byte)(uintptr(base) + uintptr(i * width))
		tmp_value := tmp_ptr^

		cur_idx := i
		next_idx := int(order[i])

		// Follow the cycle until we return to the start
		for next_idx != i {
			order[cur_idx] = u32(cur_idx)
			// Move element from next position to current position
			src_ptr := cast(^[width]byte)(uintptr(base) + uintptr(next_idx * width))
			dst_ptr := cast(^[width]byte)(uintptr(base) + uintptr(cur_idx * width))
			dst_ptr^ = src_ptr^

			cur_idx = next_idx
			next_idx = int(order[next_idx])
		}

		// Complete the cycle by placing the saved element
		order[cur_idx] = u32(cur_idx)
		dst_ptr := cast(^[width]byte)(uintptr(base) + uintptr(cur_idx * width))
		dst_ptr^ = tmp_value
	}
}

@(test)
test_basic_sort_table :: proc(t: ^testing.T) {
	data := []u32{10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
	radix_sort(data, 4)
	expected := []u32{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	for i in 0 ..< len(data) {
		testing.expect_value(t, data[i], expected[i])
	}
}

@(test)
test_sort_large_numbers :: proc(t: ^testing.T) {
	data := []u32{0x20000001, 0x20000000, 0x102030, 0x103020, 0x2010, 0x2004, 4, 3, 2, 1}
	radix_sort(data, 4)
	expected := []u32{1, 2, 3, 4, 0x2004, 0x2010, 0x102030, 0x103020, 0x20000000, 0x20000001}
	for i in 0 ..< len(data) {
		testing.expect_value(t, data[i], expected[i])
	}
}


@(test)
test_sort_struct :: proc(t: ^testing.T) {
	Value :: struct {
		key:   u64,
		value: u64,
	}
	data := make([]Value, 10)
	defer delete(data)
	expected := make([]Value, 10)
	defer delete(expected)
	for i in 0 ..< len(data) {
		data[i] = {
			key   = u64(10 - i - 1),
			value = u64(10 - i - 1) * 17,
		}
		expected[i] = {
			key   = u64(i),
			value = u64(i) * 17,
		}
	}
	radix_sort(data, 8)
	for i in 0 ..< len(data) {
		testing.expect_value(t, data[i], expected[i])
	}
}

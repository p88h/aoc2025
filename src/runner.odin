package main

import "core:fmt"
import vmem "core:mem/virtual"
import "core:slice"
import "core:time"

// Time vector: [parse, part1, part2, total]
TimeVec :: [4]u64

// Print time in appropriate units (ns, µs, ms, s)
print_time :: proc(t: u64, fmax: u64 = 99) {
	units := [?]string{"ns", "µs", "ms", "s "}
	ui: uint = 0
	d := t
	r: u64 = 0
	for d > fmax {
		r = (d % 1000) / 100
		d = d / 1000
		ui += 1
	}
	fmt.printf("\t%d.%d %s", d, r, units[ui])
}

// Compare TimeVecs by total time (last element)
cmp_by_total :: proc(a, b: TimeVec) -> bool {
	return a[3] < b[3]
}

// Run a day's solution with benchmarking
run_day :: proc(day: int, runner: DayRunner, contents: string, single: bool = false) -> u64 {
	MAX_CHUNKS :: 100
	times: [MAX_CHUNKS]TimeVec
	mid: uint = 0
	total_iter: uint = 0
	chunk_iter: uint = 10

	for cnk in 0 ..< 100 {
		fmt.printf("\rday %02d:", day)

		// Allocate contexts for this chunk
		ctxs := make([]Solution, chunk_iter)
		arena : vmem.Arena
		defer delete(ctxs)

		default_alloc := context.allocator
		context.allocator = vmem.arena_allocator(&arena)

		// Parse phase - run chunk_iter times
		start := time.now()
		for i in 0 ..< chunk_iter do ctxs[i] = runner(contents)
		parse_time := u64(time.diff(start, time.now()))
		times[cnk][0] = parse_time / u64(chunk_iter)
		print_time(times[cnk][0])

		// Part 1 phase
		start = time.now()
		a1: int = ctxs[0].part1(ctxs[0].data)
		for i in 1 ..< chunk_iter do a1 &= ctxs[i].part1(ctxs[i].data)		
		part1_time := u64(time.diff(start, time.now()))
		times[cnk][1] = part1_time / u64(chunk_iter)
		print_time(times[cnk][1])

		// Part 2 phase
		start = time.now()
		a2: int = ctxs[0].part2(ctxs[0].data)
		for i in 1 ..< chunk_iter do a2 &= ctxs[i].part2(ctxs[i].data)
		part2_time := u64(time.diff(start, time.now()))
		times[cnk][2] = part2_time / u64(chunk_iter)
		print_time(times[cnk][2])

		// Total time
		times[cnk][3] = times[cnk][0] + times[cnk][1] + times[cnk][2]

		free_all(context.allocator)
		context.allocator = default_alloc

		total_iter += chunk_iter

		if cnk >= 10 {
			// Sort by total time and compute statistics
			slice.sort_by(times[0:cnk], cmp_by_total)
			ofs := uint(cnk) / 5
			tmin := times[ofs][3]
			tmax := times[uint(cnk) - ofs][3]
			delta := 100 * (tmax - tmin) / (tmax + tmin)
			mid = uint(cnk) / 2

			fmt.printf("\rday %02d:", day)
			for i in 0 ..< 4 {
				print_time(times[mid][i])
			}
			fmt.printf(" (+-%d%%) iter=%d    ", delta, total_iter)

			if delta <= 1 {
				break
			}
		} else {
			fmt.printf("\rday %02d:", day)
			for i in 0 ..< 4 {
				print_time(times[mid][i])
			}
			fmt.printf(" (...%d) iter=%d    ", 9 - cnk, total_iter)
		}

		// Increase iterations if fast enough
		if chunk_iter < 1000 && times[0][3] * u64(chunk_iter) < 10000000 {
			chunk_iter *= 10
		}

		if single {
			fmt.printf("    p1:[%d] p2:[%d]      ", a1, a2)
		}
	}

	fmt.println()
	return times[mid][3]
}

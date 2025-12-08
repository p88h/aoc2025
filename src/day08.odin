package main

import "core:fmt"
import "core:math"
import "core:sync"
import "core:testing"
import "core:thread"

@(private = "file")
Point3D :: struct {
	x: int,
	y: int,
	z: int,
	s: int,
	c: int,
}

@(private = "file")
Wire :: struct {
	dist: u32,
	a:    int,
	b:    int,
}

@(private = "file")
SHARDS :: 12

Day8Data :: struct {
	points:  []Point3D,
	wires:   []Wire,
	shards:  [SHARDS][dynamic]Wire,
	buckets: [][dynamic]int,
	group:   sync.Wait_Group,
}

@(private = "file")
distance :: #force_inline proc(a: ^Point3D, b: ^Point3D) -> u32 {
	dx := cast(f64)(a.x - b.x)
	dy := cast(f64)(a.y - b.y)
	dz := cast(f64)(a.z - b.z)
	return u32(math.sqrt(dx * dx + dy * dy + dz * dz) * 1000.0)
}

// cube space cardinality (number of buckets per dimension)
@(private = "file")
BDIM :: 10
// search this many cubes in each direction from the current points cube
@(private = "file")
BOFS :: 1
// dimensions are in range 0..99999
@(private = "file")
BSCALE := 100000 / BDIM

@(private = "file")
bucket_index :: #force_inline proc(p: ^Point3D) -> int {
	bx := p.x / BSCALE
	by := p.y / BSCALE
	bz := p.z / BSCALE
	return bx * BDIM * BDIM + by * BDIM + bz
}

make_wires_shard :: proc(data: ^Day8Data, shard: int) {
	// limit the search space fruther to ~ diagonal of the cube)
	MAX_DISTANCE: u32 = 15_000_000
	for i in 0 ..< len(data.points) {
		if i % SHARDS != shard do continue
		bx := data.points[i].x / BSCALE
		by := data.points[i].y / BSCALE
		bz := data.points[i].z / BSCALE
		// scan the neighboring buckets
		bxs, bys, bzs :=
			min(bx + BOFS, BDIM - 1), min(by + BOFS, BDIM - 1), min(bz + BOFS, BDIM - 1)
		bxe, bye, bze := max(bx - BOFS, 0), max(by - BOFS, 0), max(bz - BOFS, 0)
		for bxi in bxe ..= bxs {
			for byi in bye ..= bys {
				for bzi in bze ..= bzs {
					bidx := bxi * BDIM * BDIM + byi * BDIM + bzi
					for j in data.buckets[bidx] {
						if j <= i {
							continue
						}
						dist := distance(&data.points[i], &data.points[j])
						if dist > MAX_DISTANCE {
							continue
						}
						wire := Wire {
							a    = i,
							b    = j,
							dist = dist,
						}
						append(&data.shards[shard], wire)
					}
				}
			}
		}
	}
}

day08 :: proc(contents: string) -> Solution {
	data := new(Day8Data)
	nums := fast_parse_all_integers(contents)
	data.points = make([]Point3D, len(nums) / 3)
	// represents a spatial partitioning of points into buckets
	data.buckets = make([][dynamic]int, BDIM * BDIM * BDIM)
	for i in 0 ..< len(nums) / 3 {
		p := Point3D {
			x = nums[i * 3 + 0],
			y = nums[i * 3 + 1],
			z = nums[i * 3 + 2],
			s = i,
			c = 1,
		}
		// assign to bucket
		bidx := bucket_index(&p)
		append(&data.buckets[bidx], i)
		data.points[i] = p
	}
	// generate all possible wires (connections) between points	
	task_proc :: proc(t: thread.Task) {
		data := cast(^Day8Data)t.data
		shard := t.user_index
		make_wires_shard(data, shard)
		sync.wait_group_done(&data.group)
	}
	for shard in 0 ..< SHARDS {
		sync.wait_group_add(&data.group, 1)
		thread.pool_add_task(&global_thread_pool, context.allocator, task_proc, data, shard)
	}
	sync.wait_group_wait(&data.group)
	total := 0
	for shard in 0 ..< SHARDS {
		total += len(data.shards[shard])
	}
	data.wires = make([]Wire, total)
	// merge shards
	ofs := 0
	for shard in 0 ..< SHARDS {
		copy(data.wires[ofs:], data.shards[shard][:])
		ofs += len(data.shards[shard])
	}
	// sort wires by distance
	radix_sort(data.wires, 3)
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
_find :: proc(data: ^Day8Data, x: int) -> int {
	if data.points[x].s != x {
		data.points[x].s = _find(data, data.points[x].s)
	}
	return data.points[x].s
}

@(private = "file")
_union :: proc(data: ^Day8Data, a: int, b: int) {
	pa := _find(data, a)
	pb := _find(data, b)
	if pa != pb {
		// swap to keep pa as the larger component
		if data.points[pa].c < data.points[pb].c {
			temp := pa
			pa = pb
			pb = temp
		}
		// expand pa set
		data.points[pb].s = pa
		data.points[pa].c += data.points[pb].c
		data.points[pb].c = 0
	}
}

@(private = "file")
MAX_CONNS := 1000

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day8Data)raw_data
	for conn in 0 ..< MAX_CONNS {
		_union(data, data.wires[conn].a, data.wires[conn].b)
	}
	// compute the sizes of top three largest components
	top3: [3]int = {0, 0, 0}
	for i in 0 ..< len(data.points) {
		size := data.points[i].c
		for j in 0 ..< 3 {
			if size > top3[j] {
				// shift down
				tmp := top3[j]
				top3[j] = size
				size = tmp
			}
		}
	}
	return top3[0] * top3[1] * top3[2]
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day8Data)raw_data
	last_size := 0
	last_res := 0
	last_dist := u32(0)
	conn := MAX_CONNS
	for last_size < len(data.points) {
		a := data.wires[conn].a
		b := data.wires[conn].b
		_union(data, a, b)
		last_size = data.points[_find(data, a)].c
		last_res = data.points[a].x * data.points[b].x
		last_dist = data.wires[conn].dist
		conn += 1
	}
	// fmt.println("Total connections used:", conn, "out of", len(data.wires))
	// fmt.println("Last distance used:", last_dist)
	return last_res
}

@(test)
test_day08 :: proc(t: ^testing.T) {
	input :=
		"162,817,812\n" +
		"57,618,57\n" +
		"906,360,560\n" +
		"592,479,940\n" +
		"352,342,300\n" +
		"466,668,158\n" +
		"542,29,236\n" +
		"431,825,988\n" +
		"739,650,466\n" +
		"52,470,668\n" +
		"216,146,977\n" +
		"819,987,18\n" +
		"117,168,530\n" +
		"805,96,715\n" +
		"346,949,466\n" +
		"970,615,88\n" +
		"941,993,340\n" +
		"862,61,35\n" +
		"984,92,344\n" +
		"425,690,689\n"
	defer setup_test_allocator()()
	solution := day08(input)
	MAX_CONNS = 10
	testing.expect_value(t, solution.part1(solution.data), 40)
	testing.expect_value(t, solution.part2(solution.data), 25272)
}

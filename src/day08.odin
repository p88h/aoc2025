package main

import "core:math"
import "core:testing"

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
    a: int,
    b: int,
}

Day8Data :: struct {
	points: []Point3D,
    wires: [dynamic]Wire,
}

distance :: #force_inline proc(a: ^Point3D, b: ^Point3D) -> u32 {
    dx := cast(f64)(a.x - b.x)
    dy := cast(f64)(a.y - b.y)
    dz := cast(f64)(a.z - b.z)
    return u32(math.sqrt(dx * dx + dy * dy + dz * dz) * 1000.0)
}

day08 :: proc(contents: string) -> Solution {
	data := new(Day8Data)
	nums := fast_parse_all_integers(contents)
    data.points = make([]Point3D, len(nums) / 3)
    for i in 0 ..< len(nums) / 3 {        
        p := Point3D{
            x= nums[i * 3 + 0],
            y= nums[i * 3 + 1],
            z= nums[i * 3 + 2],
            s= i,
            c= 1,
        }
        data.points[i] = p
    }
    data.wires = make([dynamic]Wire)
    idx := 0
    MAX_DISTANCE : u32 = 16 * 1024 * 1024
    for i in 0 ..< len(data.points) {
        for j in i + 1 ..< len(data.points) {
            dist := distance(&data.points[i], &data.points[j])
            if dist > MAX_DISTANCE {
                continue
            }
            wire := Wire{
                a= i,
                b= j,
                dist= dist
            }
            append(&data.wires, wire)
        }
    }
    // sort wires by distance
    radix_sort(data.wires[:], 4)
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
_find :: proc(data:^Day8Data, x: int) -> int {
    if data.points[x].s != x {
        data.points[x].s = _find(data, data.points[x].s)
    }
    return data.points[x].s
}

@(private = "file")
_union :: proc(data:^Day8Data, a: int, b: int) {
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
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day8Data)raw_data
    for conn in 0..< 1000 {
        _union(data, data.wires[conn].a, data.wires[conn].b)
    }
    // compute the sizes of top three largest components
    top3 : [3]int = {0, 0, 0}
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
    conn := 0
    for last_size < len(data.points) {
        a := data.wires[conn].a
        b := data.wires[conn].b
        _union(data, a, b)
        last_size = data.points[_find(data, a)].c
        last_res = data.points[a].x * data.points[b].x
        conn += 1        
    }
    // fmt.println("Total connections used:", conn, "out of", len(data.wires))
	return last_res
}

@(test)
test_day08 :: proc(t: ^testing.T) {
	input := "162,817,812\n" +
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
	testing.expect_value(t, solution.part1(solution.data), 40)
	// testing.expect_value(t, solution.part2(solution.data), 12)
}

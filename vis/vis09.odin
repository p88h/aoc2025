package vis

import sol "../src"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	lines: []string,
	nums: [dynamic]int,
    len:   int,    
    max1: [4]int,
    max2: [4]int,
}

// Initialize the example visualization
vis09_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day09.txt")
    vis.nums = sol.fast_parse_all_integers(string(contents))
    vis.len = len(vis.nums) / 2
    part2(vis)
	return vis
}

part2 :: proc(data: ^VisState) -> int {    
    ret1 := 0
    ret2 := 0
    i := 248
        k := 0
        maxx: = 0
        x1, y1 := data.nums[i*2], data.nums[i*2+1]
        for j:=i-1; j>=0; j-=1 {
            x2, y2 := data.nums[j*2], data.nums[j*2+1]
            if x2 < maxx do continue
            // find corresponding point
            for data.nums[k*2+1] < y2 {
                k += 1
            }
            if data.nums[k*2] < x1 do break            
            maxx = x2
            area := (abs(x2 - x1) + 1)* (abs(y2 - y1) + 1)
            if area > ret1 {
                ret1 = area
                data.max1 = [4]int{x1, y1, x2, y2}
            }            
        }
    i = 249
        x1, y1 = data.nums[i*2], data.nums[i*2+1]
        k = data.len - 1
        maxx = 0
        for j in i+1..<data.len {
            x2, y2 := data.nums[j*2], data.nums[j*2+1]
            if x2 < maxx do continue
            maxx = x2   
            for data.nums[k*2+1] > y2 {
                k -= 1
            }
            if data.nums[k*2] < x1 do break
            area := (abs(x2 - x1) + 1)* (abs(y2 - y1) + 1)
            if area > ret2 {
                ret2 = area
                data.max2 = [4]int{x1, y1, x2, y2}
            }
        }
    fmt.println("Max areas are ", ret1, " and ", ret2)
	return ret2
}

@(private = "file")
SCALE :: 75

vis09_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
    // draw all lines between consecutive points, start from last
    cx, cy := vis.nums[vis.len*2-2], vis.nums[vis.len*2-1]
    for i in 0 ..< vis.len {
        x, y := vis.nums[i*2], vis.nums[i*2+1]
        rl.DrawLine(i32(cx / SCALE), i32(cy/SCALE), i32(x/SCALE), i32(y/SCALE), rl.WHITE)
        cx, cy = x, y
    }
    // highlight max areas
    rl.DrawRectangleLines(
        i32(vis.max1[0]/SCALE),
        i32(vis.max1[1]/SCALE),
        i32((vis.max1[2] - vis.max1[0] + SCALE)/SCALE),
        i32((vis.max1[3] - vis.max1[1] + SCALE)/SCALE),
        rl.RED,
    )
    rl.DrawRectangleLines(
        i32(vis.max2[0]/SCALE),
        i32(vis.max2[1]/SCALE),
        i32((vis.max2[2] - vis.max2[0] + SCALE)/SCALE),
        i32((vis.max2[3] - vis.max2[1] + SCALE)/SCALE),
        rl.GREEN,
    )

	return false
}

// Boilerplate handler for the example visualization
VIS09 :: Handler {
	init = vis09_init,
	step = vis09_step,
	window = Window{width = 1440, height = 1440, fps = 30, fsize = 24},
}

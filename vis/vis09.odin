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
	data:  ^sol.Day9Data,
}

// Initialize the example visualization
vis09_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day09.txt")
	vis.data = cast(^sol.Day9Data)sol.day09(string(contents)).data
	return vis
}

@(private = "file")
SCALE :: 100

vis09_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	data := vis.data
	// draw all lines between consecutive points, start from last
	cx, cy := data.nums[data.len * 2 - 2], data.nums[data.len * 2 - 1]
	for i in 0 ..< data.len {
		x, y := data.nums[i * 2], data.nums[i * 2 + 1]
		rl.DrawLine(i32(cx / SCALE), i32(cy / SCALE), i32(x / SCALE), i32(y / SCALE), rl.WHITE)
		cx, cy = x, y
	}
    if idx < 1 {
        return false
    }
	_, j := sol.day9_scan_from(data, data.pos, 1, int(idx))
	x1, y1 := data.nums[data.pos * 2], data.nums[data.pos * 2 + 1]
	x2, y2 := data.nums[j * 2], data.nums[j * 2 + 1]
	// draw rectangle around the best area
	rx1, ry1 := i32(min(x1, x2)) / SCALE, i32(min(y1, y2)) / SCALE
    rw, rh := i32(abs(x2 - x1) + 1) / SCALE, i32(abs(y2 - y1) + 1) / SCALE
    rl.DrawRectangleLines(rx1, ry1, rw, rh, rl.RED)
    // print the area in the center of the rectangle
    area := (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
    area_str := fmt.tprintf("Area: %d", area)
    asciiray_write_at(a, area_str, i32(rx1 + rw / 2 - 48), i32(ry1 + rh / 2 - 10), rl.YELLOW)
    // after 50 frames, also show the other direction
    if idx > 50 {
        _, j := sol.day9_scan_from(data, data.pos + 1, -1, int(idx - 50))
        x1, y1 = data.nums[data.pos * 2 + 2], data.nums[data.pos * 2 + 3]
        x2, y2 = data.nums[j * 2], data.nums[j * 2 + 1]
        // draw rectangle around the best area
        rx1, ry1 := i32(min(x1, x2)) / SCALE, i32(min(y1, y2)) / SCALE
        rw, rh := i32(abs(x2 - x1) + 1) / SCALE, i32(abs(y2 - y1) + 1) / SCALE
        rl.DrawRectangleLines(rx1, ry1, rw, rh, rl.GREEN)
        area := (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
        area_str = fmt.tprintf("Area: %d", area)
        asciiray_write_at(a, area_str, i32(rx1 + rw / 2 - 48), i32(ry1 + rh / 2 - 10), rl.YELLOW)
	}
    return idx >= 100
}

// Boilerplate handler for the example visualization
VIS09 :: Handler {
	init = vis09_init,
	step = vis09_step,
	window = Window{width = 1000, height = 1000, fps = 10, fsize = 24},
}

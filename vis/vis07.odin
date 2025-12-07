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
	start: int,
    delay: int,
}

// Initialize the example visualization
vis07_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day07.txt")
	vis.lines = sol.split_lines(string(contents))
	vis.start = strings.index(vis.lines[0], "S")
	return vis
}

vis07_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	cell := int(a.v.width) / len(vis.lines[0])
	// draw the grid, each ^ becomes a 'prism' i.e. a triangle
	beams := make([]int, len(vis.lines[0]))
    defer delete(beams)
	beams[vis.start] = 1
	for y: int = 0; y < len(vis.lines); y += 1 {
		line := vis.lines[y]
		for x: int = 0; x < len(line); x += 1 {
			ch := line[x]
			if ch == '^' {
				rl.DrawTriangleLines(
					rl.Vector2{f32(x * cell + cell / 2), f32(y * cell)},
					rl.Vector2{f32(x * cell - cell / 2), f32(y * cell + cell)},
					rl.Vector2{f32(x * cell + cell + cell / 2), f32(y * cell + cell)},
					rl.DARKBLUE,
				)
			}
		}
	}
	next_beams := make([]int, len(beams))
    defer delete(next_beams)
	limit := int(idx) / cell
    if limit > len(vis.lines) - 1 {
        limit = len(vis.lines) - 1
        vis.delay += 1
    }
	for i in 0 ..= limit {
        step := cell if vis.delay > 0 || i < limit else int(idx) % cell
        // step = (step * step) / cell // ease out
		for j in 0 ..< len(beams) do next_beams[j] = 0
		for x in 0 ..< len(beams) do if beams[x] > 0 {
			ch := vis.lines[i][x]
            sx := x * cell + cell / 2
            sy := i * cell
			if ch == '^' {
				next_beams[x + 1] += beams[x]
				next_beams[x - 1] += beams[x]
				// draw two lines, one from top of triangle at (x, i) to (x-1, i+1) and (x+1, i+1)
				rl.DrawLine(i32(sx), i32(sy), i32(sx - step), i32(sy + step), rl.LIGHTGRAY)
				rl.DrawLine(i32(sx), i32(sy), i32(sx + step), i32(sy + step), rl.LIGHTGRAY)
                // 'activate' this triangle by highlighting it proportionally to log2 of beam size
                alpha := 64 + u8(math.log2(f64(beams[x])) * f64(step) / 2)
				rl.DrawTriangle(
					rl.Vector2{f32(x * cell + cell / 2), f32(i * cell)},
					rl.Vector2{f32(x * cell - cell / 2), f32(i * cell + cell)},
					rl.Vector2{f32(x * cell + cell + cell / 2), f32(i * cell + cell)},
					rl.Color{255,128,255,alpha},
				)
			} else {
				next_beams[x] += beams[x]
				// draw one line straight down
				rl.DrawLine(i32(sx), i32(sy), i32(sx), i32(sy + step), rl.LIGHTGRAY)
			}
		}
		for j in 0 ..< len(beams) do beams[j] = next_beams[j]
	}
	return vis.delay > 100
}

// Boilerplate handler for the example visualization
VIS07 :: Handler {
	init = vis07_init,
	step = vis07_step,
	window = Window{width = 1128, height = 1136, fps = 60, fsize = 24},
}

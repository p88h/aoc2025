package vis

import sol "../src"
import "core:os"
import "core:slice"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	data:   ^sol.Day4Input,
	// solved paths
	points: [dynamic]int,
	delay:  int,
}

// Initialize the example visualization
vis04_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day04.txt")
	vis.data = cast(^sol.Day4Input)sol.day04(string(contents)).data
	vis.points = sol.day4_find_start_pos(vis.data)
	slice.reverse(vis.points[:])
	vis.delay = 10
	return vis
}

// Step the example visualization
vis04_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	// display grid
	for i in 1 ..= vis.data.height {
		for j in 1 ..= vis.data.width {
			val := vis.data.grid[i][j]
			color := rl.WHITE
			if val < 0 {
				color = rl.DARKGRAY
			} else if val > 3 {
				color = rl.BLUE
			} else if val == 3 {
				color = rl.LIME
			} else {
				color = rl.GREEN
			}
			rl.DrawRectangle(i32(j * 8) - 8, i32(i * 8) - 8, 7, 7, color)
		}
	}
	if len(vis.points) == 0 {
		return true
	}
	tmp := [2]int{}
	for i in 0 ..< 2 {
		if len(vis.points) == 0 {
			break
		}
		tmp[i] = pop(&vis.points)
	}
	for last in tmp {
		if last == 0 {
			continue
		}
		row := last >> 8
		col := last & 0xFF
		rl.DrawRectangle(i32(col * 8) - 8, i32(row * 8) - 8, 7, 7, rl.RED)
		sol.day4_remove_cell(vis.data, &vis.points, row, col)
	}
	return false
}

// Boilerplate handler for the example visualization
VIS04 :: Handler {
	init = vis04_init,
	step = vis04_step,
	window = Window{width = 1080, height = 1080, fps = 60, fsize = 24},
}

package vis

import sol "../src"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	data:       ^sol.Day3Input,
	// solved paths
	lines:      []string,
	best_paths: [dynamic][12]int,
	// candidate paths for the current line
	cur_paths:  [dynamic][12]int,
	// index into cur_paths
	cur_pos:    int,
}

// Initialize the example visualization
vis03_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day03.txt")
	vis.data = cast(^sol.Day3Input)sol.day03(string(contents)).data
	vis.lines = sol.split_lines(string(contents))
	vis.cur_paths = make([dynamic][12]int)
	vis.best_paths = make([dynamic][12]int)
	vis.cur_pos = 0
	return vis
}

// Step the example visualization
vis03_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	if vis.cur_pos >= len(vis.cur_paths) {
		if len(vis.cur_paths) > 0 {
			append(&vis.best_paths, vis.cur_paths[len(vis.cur_paths) - 1])
		}
		clear(&vis.cur_paths)
		sol := 0
		pos := 0
		path: [12]int = {}
		width := vis.data.width
		for k in 0 ..< 12 {
			path[k] = -1
		}
		idx := len(vis.best_paths)
		for k in 0 ..< 12 {
			// find next best digit to use
			for d in 1 ..< 10 {
				rd := (10 - d)
				d_pos := cast(int)(vis.data.next[idx][pos] >> (cast(uint)(rd - 1) * 7) & 0x7F)
				// display all considered paths
				if d_pos < width {
					path[k] = d_pos
					append(&vis.cur_paths, path)
				}
				if d_pos + (12 - k - 1) < width {
					sol = sol * 10 + rd
					pos = d_pos + 1
					break
				}
			}
		}
		vis.cur_pos = 0
	}
	for idx in 0 ..< len(vis.best_paths) {
		path := vis.best_paths[idx]
		asciiray_write_xy(a, vis.lines[idx], 0, cast(i32)(idx), rl.LIGHTGRAY)
		for k in 0 ..< 12 {
			j := path[k]
			asciiray_write_xy(a, vis.lines[idx][j:j + 1], cast(i32)(j), cast(i32)(idx), rl.GREEN)
		}
	}
	idx := len(vis.best_paths)
	if idx == 30 {
		return true
	}
	asciiray_write_xy(a, vis.lines[idx], 0, cast(i32)(idx), rl.DARKGRAY)
	if vis.cur_pos < len(vis.cur_paths) {
		path := vis.cur_paths[vis.cur_pos]
		for k in 0 ..< 12 {
			if path[k] == -1 {
				break
			}
			j := path[k]
			col := rl.RED if k == 11 || path[k + 1] == -1 else rl.YELLOW
			asciiray_write_xy(a, vis.lines[idx][j:j + 1], cast(i32)(j), cast(i32)(idx), col)
		}
		vis.cur_pos += 1
	}
	return false
}

// Boilerplate handler for the example visualization
VIS03 :: Handler {
	init = vis03_init,
	step = vis03_step,
	window = Window{width = 1280, height = 720, fps = 10, fsize = 24},
}

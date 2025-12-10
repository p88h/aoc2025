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
	data:  ^sol.Day10Data,
	rows:  [][]u16,
    heights: []int,
}

@(private = "file")
make_bfs_queue :: proc(data: ^sol.Day10Data, idx: int) -> []u16 {
	config := data.lines[idx]
	states := make([dynamic]u16)
	visited := [1024]int{}
	append(&states, 0)
	visited[0] = 1
	idx := 0
	for idx < len(states) {
		state := states[idx]
		idx += 1
		// check if we reached the target
		distance := visited[state]
		if state == config.mask {
			return states[0:idx]
		}
		// try all buttons
		for button in config.buttons {
			next_state := state ~ button
			if visited[next_state] == 0 {
				visited[next_state] = distance + 1
				append(&states, next_state)
			}
		}
	}
	return states[:]
}

// Initialize the example visualization
vis10_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day10.txt")
	vis.data = cast(^sol.Day10Data)sol.day10(string(contents)).data
    vis.rows = make([][]u16, len(vis.data.lines))
    for i in 0 ..< len(vis.data.lines) do vis.rows[i] = make_bfs_queue(vis.data, i)
    vis.heights = make([]int, len(vis.data.lines))
    for i in 0 ..< len(vis.data.lines) { 
        for button in vis.data.lines[i].buttons {
            h := 0
            // height is the highest bit set in button
            for b in 0 ..< 10 {
                if (button & (1 << u16(b))) != 0 {
                    h = b
                }
            }
            vis.heights[i] = max(vis.heights[i], h + 1)
        }        
    }
	return vis
}

vis10_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	data := vis.data
    // draw each row as a horizontal bar of states, up to the limit of idx - line_id
    ADD_DELAY :: 5
    ROW_HEIGHT :: 32
    CELL_SIZE :: 4
    CELL_STEP :: 5
    ofs_y := 10
    all_done := true
    for line_id in 0 ..< len(data.lines) {
        states := vis.rows[line_id]
        // we should start displaying line X at frame X * ADD_DELAY
        limit := int(idx) - line_id * ADD_DELAY
        if limit < 0 do continue
        // skip if solved after 1 sec
        if limit > len(states) + 30 do continue
        all_done = false
        if limit > len(states) do limit = len(states)
        ofs_x := 10
        start := 0
        if limit >= 1900 / CELL_STEP do start = limit - (1900 / CELL_STEP)
        for state_id in start ..< limit {
            for bit in 0 ..< 10 {
                if (states[state_id] & (1 << u16(bit))) != 0 {
                    x := i32(ofs_x)
                    y := i32(ofs_y + bit * CELL_STEP)
                    col := rl.YELLOW if vis.data.lines[line_id].mask & (1 << u16(bit)) != 0 else rl.RED;
                    rl.DrawRectangle(x, y, CELL_SIZE, CELL_SIZE, col)
                }
            }
            ofs_x += CELL_STEP
        }
        ofs_y += (vis.heights[line_id] + 1) * CELL_STEP
    }
	return all_done
}

// Boilerplate handler for the example visualization
VIS10 :: Handler {
	init = vis10_init,
	step = vis10_step,
	window = Window{width = 1920, height = 1000, fps = 30, fsize = 24},
}

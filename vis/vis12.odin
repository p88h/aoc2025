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
	data:      ^sol.Day12Data,
	idx:       int,
	counters:  [6]int,
	state:     [64][64]int,
	bid:       int,
	cur:       sol.Block,
	px:        int,
	py:        int,
	undo:      [dynamic]Combo,
	macro:     [dynamic]Combo,
	recording: bool,
}

Combo :: struct {
	dx:    int,
	dy:    int,
	block: sol.Block,
}

// Initialize the example visualization
vis12_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day12.txt")
	vis.data = cast(^sol.Day12Data)sol.day12(string(contents)).data
	vis.idx = 0
	vis.bid = 0
	vis.cur = vis.data.blocks[0]
    audio_init(a.v)
	return vis
}


undo_place :: proc(vis: ^VisState) {
	if len(vis.undo) == 0 {
		return
	}
	cmd := pop(&vis.undo)
	// remove the block placed at (cmd.dx, cmd.dy)
	for by := 0; by < 3; by += 1 {
		for bx := 0; bx < 3; bx += 1 {
			if cmd.block.grid[by][bx] {
				x := cmd.dx + bx
				y := cmd.dy + by
				vis.state[y][x] = 0
			}
		}
	}
	vis.counters[cmd.block.id] -= 1
}

try_place :: proc(vis: ^VisState, region: sol.Region, block: sol.Block, gx: int, gy: int) -> bool {
	if vis.counters[block.id] >= region.counts[block.id] {
		return false
	}
	// check if block can be placed at (gx, gy)
	for by := 0; by < 3; by += 1 {
		for bx := 0; bx < 3; bx += 1 {
			if block.grid[by][bx] {
				x := gx + bx
				y := gy + by
				if x < 0 ||
				   y < 0 ||
				   x >= region.width ||
				   y >= region.height ||
				   vis.state[y][x] != 0 {
					return false
				}
			}
		}
	}
	vis.counters[block.id] += 1
	if vis.recording {
		if len(vis.macro) > 0 {
			vis.macro[len(vis.macro) - 1].dx = gx - vis.px
			vis.macro[len(vis.macro) - 1].dy = gy - vis.py
		}
		append(&vis.macro, Combo{block = block})
	}
	vis.px = gx
	vis.py = gy
	// place the block
	for by := 0; by < 3; by += 1 {
		for bx := 0; bx < 3; bx += 1 {
			if block.grid[by][bx] {
				x := gx + bx
				y := gy + by
				vis.state[y][x] = block.id + 1
			}
		}
	}
	append(&vis.undo, Combo{dx = gx, dy = gy, block = block})
	return true
}

vis12_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	data := vis.data
	// draw the grid for the current region
	if vis.idx >= len(data.regions) {
		return true
	}
	region := data.regions[vis.idx]
	// light hues of green and blue for the blocks
	COLOR_PALLETTE := [6]rl.Color {
		rl.Color{150, 255, 150, 255},
		rl.Color{150, 150, 255, 255},
		rl.Color{255, 150, 150, 255},
		rl.Color{255, 255, 150, 255},
		rl.Color{150, 255, 255, 255},
		rl.Color{255, 150, 255, 255},
	}
	CELL_SIZE :: 20
	for y := 0; y < region.height; y += 1 {
		for x := 0; x < region.width; x += 1 {
			if vis.state[y][x] != 0 {
				// generate a color based on the block id in the cell (0-5)
				rl.DrawRectangle(
					cast(i32)(x * CELL_SIZE + 1),
					cast(i32)(y * CELL_SIZE + 1),
					CELL_SIZE - 2,
					CELL_SIZE - 2,
					COLOR_PALLETTE[vis.state[y][x] - 1],
				)
			} else {
				rl.DrawRectangleLines(
					cast(i32)(x * CELL_SIZE + 1),
					cast(i32)(y * CELL_SIZE + 1),
					CELL_SIZE - 2,
					CELL_SIZE - 2,
					rl.DARKGRAY,
				)
			}
		}
	}
	// get the mouse position to place the block
	mouse := rl.GetMousePosition()
	grid_x := cast(int)((mouse.x) / CELL_SIZE)
	grid_y := cast(int)((mouse.y) / CELL_SIZE)
	// draw the current block at the mouse position
	for by := 0; by < 3; by += 1 {
		for bx := 0; bx < 3; bx += 1 {
			if vis.cur.grid[by][bx] {
				rl.DrawRectangle(
					cast(i32)(grid_x * CELL_SIZE + bx * CELL_SIZE + 1),
					cast(i32)(grid_y * CELL_SIZE + by * CELL_SIZE + 1),
					CELL_SIZE - 2,
					CELL_SIZE - 2,
					rl.DARKGRAY,
				)
			}
		}
	}

    // Input handling begins
    tone := 0
	// React to keys to rotate/flip/place the block
	if rl.IsKeyPressed(rl.KeyboardKey.N) {
		vis.bid = (vis.bid + 1) % len(data.blocks)
		vis.cur = data.blocks[vis.bid]
        tone = 60
	}
	if rl.IsKeyPressed(rl.KeyboardKey.R) {
		vis.cur = sol.rotate_block(vis.cur)
        tone = 70
	}
	if rl.IsKeyPressed(rl.KeyboardKey.F) {
		vis.cur = sol.flip_block(vis.cur)
        tone = 80
	}
	if rl.IsKeyPressed(rl.KeyboardKey.M) {
		vis.recording = !vis.recording
		if vis.recording {
			clear(&vis.macro)
		} else if len(vis.macro) > 0 {
			// stitch the macro -- undo last move first
			undo_place(vis)
			pop(&vis.macro)
		}
	}
	if rl.IsKeyPressed(rl.KeyboardKey.A) && len(vis.macro) > 0 {
		// apply macro at current position
		vis.px = grid_x
		vis.py = grid_y
		pos := 0
		for {
			cmd := vis.macro[pos]
			if !try_place(vis, region, cmd.block, vis.px, vis.py) {
				break
			}
			vis.px += cmd.dx
			vis.py += cmd.dy
			pos = (pos + 1) % len(vis.macro)
		}
        tone = 50
	}
	if rl.IsMouseButtonDown(rl.MouseButton.LEFT) || rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
		if (try_place(vis, region, vis.cur, grid_x, grid_y)) {
            tone = 50
        } else {
            tone = 20
        }
	}
	if rl.IsKeyPressed(rl.KeyboardKey.BACKSPACE) || rl.IsKeyPressed(rl.KeyboardKey.U) {
        tone = 30
		undo_place(vis)
		if (vis.recording && len(vis.macro) > 0) {
			pop(&vis.macro)
			vis.px -= vis.macro[len(vis.macro) - 1].dx
			vis.py -= vis.macro[len(vis.macro) - 1].dy
			vis.macro[len(vis.macro) - 1].dx = 0
			vis.macro[len(vis.macro) - 1].dy = 0
		}
	}
	// advance to next region if complete or on Enter
	complete := true
	for bidx := 0; bidx < len(data.blocks); bidx += 1 do if vis.counters[bidx] < region.counts[bidx] {
		complete = false
	}
	clear := false
	if complete || rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		vis.idx += 1
		clear = true
        tone = 20
	}
	if clear || rl.IsKeyPressed(rl.KeyboardKey.C) {
		// reset state
		for y := 0; y < 64; y += 1 {
			for x := 0; x < 64; x += 1 {
				vis.state[y][x] = 0
			}
		}
		for i := 0; i < len(vis.counters); i += 1 {
			vis.counters[i] = 0
		}
		vis.px = 0
		vis.py = 0
        tone = 20
	}


	// show board dimensions and overall sum of counters
	info_str := fmt.aprintf("Region %d: %dx%d", vis.idx + 1, region.width, region.height)
	asciiray_write_at(a, info_str, 1050, 10, rl.LIGHTGRAY)
	area := region.width * region.height
	covered := 0
	required := 0
	for c, i in region.counts do required += data.blocks[i].tiles * c
	for c, i in vis.counters do covered += data.blocks[i].tiles * c
	area_pct := cast(f32)(required) / cast(f32)(area) * 100.0
	cover_pct := cast(f32)(covered) / cast(f32)(required) * 100.0
	status_str := fmt.tprintf("Required: %d / %d (%.1f%%)", required, area, area_pct)
	asciiray_write_at(a, status_str, 1050, 40, rl.LIGHTGRAY)
	cover_str := fmt.tprintf("Progress: %d / %d (%.1f%%)", covered, required, cover_pct)
	asciiray_write_at(a, cover_str, 1050, 70, rl.LIGHTGRAY)

	// display the task (show blocks and required counts)
	for bidx := 0; bidx < len(data.blocks); bidx += 1 {
		block := data.blocks[cast(int)bidx]
		// draw block at the right side
		offset_x := cast(i32)(1050 + (bidx % 2) * CELL_SIZE * 6)
		offset_y := cast(i32)((bidx / 2) * CELL_SIZE * 6 + 150)
		for by := 0; by < 3; by += 1 {
			for bx := 0; bx < 3; bx += 1 {
				if block.grid[by][bx] {
					rl.DrawRectangle(
						offset_x + cast(i32)(bx * CELL_SIZE + 1),
						offset_y + cast(i32)(by * CELL_SIZE + 1),
						CELL_SIZE - 2,
						CELL_SIZE - 2,
						rl.LIGHTGRAY,
					)
				}
			}
		}
		// draw counts
		col := rl.LIGHTGRAY if vis.counters[bidx] < region.counts[bidx] else rl.GREEN
		count_str := fmt.aprintf("%v / %v", vis.counters[bidx], region.counts[bidx])
		asciiray_write_at(
			a,
			count_str,
			offset_x + 12,
			offset_y + cast(i32)(3 * CELL_SIZE + 10),
			col,
		)
	}

	// show the current macro below the blocks
	macro_y := cast(i32)(len(data.blocks) * CELL_SIZE * 6 + 70)
	if vis.recording {
		asciiray_write_at(a, "Recording:", 1050, macro_y, rl.YELLOW)
	} else if len(vis.macro) > 0 {
		asciiray_write_at(a, "Macro:", 1050, macro_y, rl.YELLOW)
	}
	mx := i32(1050)
	my := macro_y + 20
	for cmd in vis.macro {
		cmd_str := fmt.aprintf("[dx=%d,dy=%d]", cmd.dx, cmd.dy)
		asciiray_write_at(a, cmd_str, mx, my, rl.LIGHTGRAY)
		// show a miniature of the block
		MINI_CELL :: 7
		for by := 0; by < 3; by += 1 {
			for bx := 0; bx < 3; bx += 1 {
				if cmd.block.grid[by][bx] {
					rl.DrawRectangle(
						mx + cast(i32)(len(cmd_str) * 12) + 12 + cast(i32)(bx * MINI_CELL + 1),
						my + cast(i32)(by * MINI_CELL + 1),
						MINI_CELL - 2,
						MINI_CELL - 2,
						rl.DARKGRAY,
					)
				}
			}
		}
		my += 24
	}

    if tone > 0 {
        make_beep(piano_keys(tone), 0.5, 0.02)
    } else {
        make_noise(0, 0)
    }

	return false
}

// Boilerplate handler for the example visualization
VIS12 :: Handler {
	init = vis12_init,
	step = vis12_step,
	window = Window{width = 1500, height = 1000, fps = 20, fsize = 24},
}

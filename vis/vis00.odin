package vis

import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	posy: [120]int,
    state: [120]int,
	tex:  rl.RenderTexture2D,
    message: string,
    num_done: uint,
    delay: uint,
}

// Initialize the example visualization
vis00_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	vis.tex = rl.LoadRenderTexture(a.v.width, a.v.height)
    vis.message = "...@.#.   _.-*-._   A D V E N T   O F   C O D E   2 0 2 5   _.-*-._   .#.@..."
	rl.BeginTextureMode(vis.tex)
	// generate matrix lines to display - each line is a string of random characters
	for row := 0; row < 34; row += 1 {
		line := make([dynamic]u8, 0, 120)
		for j: i32 = 0; j < 120; j += 1 {
			c := ' ' + rand.int31_max(95)
			append(&line, cast(u8)c)
		}
		asciiray_write_at(a, strings.clone_from_bytes(line[:]), 0, cast(i32)(row * 32 - 2), rl.WHITE)
	}
	rl.EndTextureMode()

	// randomize starting positions
	for col := 0; col < 120; col += 1 {
		vis.posy[col] = cast(int)rand.int31_max(45) - 11
        vis.state[col] = 0;
	}
	return vis
}

// Step the example visualization
vis00_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
    if vis.num_done == 120 {
        vis.delay += 1
    } 
	if vis.delay > 120 {
        return true
	}
	// display the matrix effect - for every column print 12 characters starting from posy
	// using the rendered texture buffer as source
	for col := 0; col < 120; col += 1 {
        limit := 11
        if vis.state[col] == 1 && vis.posy[col] == 4 {
            vis.state[col] = 2;
        }
        if vis.state[col] == 2 {
            limit = 15 - vis.posy[col];
        }
        if limit == 0 && vis.state[col] != 3 {
            vis.state[col] = 3;
            vis.num_done += 1;
        }
        if vis.state[col] == 3 {
            limit = 0;
        }
		y := vis.posy[col]
        if limit > 0 {
            rl.DrawTexturePro(
                vis.tex.texture,
                rl.Rectangle{cast(f32)(col * 16), cast(f32)(y * 32), 16, cast(f32)(32 * limit)},
                rl.Rectangle{cast(f32)(col * 16), cast(f32)(y * 32), 16, cast(f32)(32 * limit)},
                rl.Vector2{0, 0},
                0.0,
                rl.GREEN,
            )
            // last character in bright white
            rl.DrawTexturePro(
                vis.tex.texture,
                rl.Rectangle{cast(f32)(col * 16), cast(f32)((y + 11) * 32), 16, 32},
                rl.Rectangle{cast(f32)(col * 16), cast(f32)((y + limit) * 32), 16, 32},
                rl.Vector2{0, 0},
                0.0,
                rl.WHITE,
            )
        } else {
            msg_len := len(vis.message)
            msg_start := 60 - msg_len / 2
            if col >= msg_start && col < msg_start + msg_len {
                asciiray_write_xy(a, vis.message[col - msg_start:col - msg_start+1], cast(i32)col, 15, rl.WHITE)
                continue;
            }

        }
		if cast(uint)col % 3 == idx % 3 {
			// advance position for this column
			vis.posy[col] += 1
			if vis.posy[col] > 40 {
				vis.posy[col] = -12
			}
		}
	}
    if idx % 10 == 0 {
        // switch one more column into 'stop' state
        col := ((idx / 10) * 7) % 120;
        if vis.state[col] == 0 {
            vis.state[col] = 1;
        }
    }
	return false
}

// Boilerplate handler for the example visualization
VIS00_HANDLER :: Handler {
	init = vis00_init,
	step = vis00_step,
	window = Window{width = 1920, height = 1080, fps = 30, fsize = 32},
}

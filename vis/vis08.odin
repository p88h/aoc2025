package vis

import sol "../src"
import "core:fmt"
import "core:math"
import "core:os"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	data:   ^sol.Day8Data,
	start:  int,
	delay:  int,
	camera: rl.Camera3D,
	angle:  f32, // current orbit angle
    conns:  [dynamic]int,
    color:  [dynamic]rl.Color,
}

@(private = "file")
SCALE :: 0.001 // Scale down coordinates to avoid z-buffer issues
CENTER :: f32(50) // center of scaled space
DIST :: f32(150) // distance from center to see whole cube

// Initialize the example visualization
vis08_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day08.txt")
	vis.data = cast(^sol.Day8Data)sol.day08(string(contents)).data
	vis.angle = 0
	// Position camera at corner, looking at center of the cube
	vis.camera = rl.Camera3D {
		position   = rl.Vector3{CENTER + DIST, CENTER + DIST * 0.5, CENTER + DIST},
		target     = rl.Vector3{CENTER, CENTER * 0.9, CENTER},
		up         = rl.Vector3{0, 1, 0},
		fovy       = 45,
		projection = .PERSPECTIVE,
	}
    for i in 0 ..< len(vis.data.points) {
        c := sol.day8_find(vis.data, i)
        col := rl.Color{u8((c * 37) % 256), u8((c * 59) % 256), u8((c * 83) % 256), 255}
        append(&vis.color, col)
    }
	return vis
}

vis08_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx

	// Auto-orbit camera around center
	vis.angle += 0.005 // rotation speed
	vis.camera.position.x = CENTER + DIST * math.cos(vis.angle)
	vis.camera.position.z = CENTER + DIST * math.sin(vis.angle)
	vis.camera.position.y = CENTER + DIST * 0.5 // keep height constant

	rl.BeginMode3D(vis.camera)
	// Draw all points in  3D space
	for p,idx in vis.data.points {
		// color based on the cluster number
		c := sol.day8_find(vis.data, idx)
		tgt_col := rl.Color{u8((c * 37) % 256), u8((c * 59) % 256), u8((c * 83) % 256), 255}
        col := vis.color[idx]
        // simple color lerp for smooth transition
        col.r = u8((int(col.r) * 7 + int(tgt_col.r)) / 8)
        col.g = u8((int(col.g) * 7 + int(tgt_col.g)) / 8)
        col.b = u8((int(col.b) * 7 + int(tgt_col.b)) / 8)
        vis.color[idx] = col

		rl.DrawCube(
			rl.Vector3{f32(p.x) * SCALE, f32(p.y) * SCALE, f32(p.z) * SCALE},
			0.3,
			0.3,
			0.3,
			col,
		)
	}

    pos := min(int(idx), len(vis.data.wires) - 1)
	// draw last 25 evaluated wires with fading effect
	start_pos := max(pos - 30, 0)
	for i in start_pos ..= pos {
		wire := vis.data.wires[i]
        pa := vis.data.points[wire.a]
        pb := vis.data.points[wire.b]        
        fade := f32(int(idx) - i - 15) / 16.0
        alpha := u8(255 * (1 - fade*fade))
        color := rl.Color{255, 255, 255, alpha}
        rl.DrawLine3D(
            rl.Vector3{f32(pa.x) * SCALE, f32(pa.y) * SCALE, f32(pa.z) * SCALE},
            rl.Vector3{f32(pb.x) * SCALE, f32(pb.y) * SCALE, f32(pb.z) * SCALE},
            color,
        )
    }

    // execute step of the joining process
    if pos >= 15 {
        pos -= 15
        wire := vis.data.wires[pos]
        // check if already connected
        sa := sol.day8_find(vis.data, wire.a)
        sb := sol.day8_find(vis.data, wire.b)
        if sa != sb {
            append(&vis.conns, pos)
            sol.day8_union(vis.data, wire.a, wire.b)
        }
    }

	// draw already connected wires
	for i in vis.conns {
		wire := vis.data.wires[i]
		pa := vis.data.points[wire.a]
		pb := vis.data.points[wire.b]
		// color based on the cluster number
		c := sol.day8_find(vis.data, wire.a)
		col := vis.color[wire.a]
		rl.DrawLine3D(
			rl.Vector3{f32(pa.x) * SCALE, f32(pa.y) * SCALE, f32(pa.z) * SCALE},
			rl.Vector3{f32(pb.x) * SCALE, f32(pb.y) * SCALE, f32(pb.z) * SCALE},
			col,
		)
	}
	rl.EndMode3D()
	// Debug info
	msg := fmt.tprintf("Evaluated %d/%d wires, Connections: %d",
        pos + 1,
        len(vis.data.wires),
        len(vis.conns),
    )

	// execute union find for the last wire
	a.cx, a.cy = 10, 10
	asciiray_write(a, msg, rl.WHITE)
	if idx >= uint(len(vis.data.wires)) {
		vis.delay += 1
	}
	return vis.delay > 30
}

// Boilerplate handler for the example visualization
VIS08 :: Handler {
	init = vis08_init,
	step = vis08_step,
	window = Window{width = 1024, height = 768, fps = 30, fsize = 20},
}

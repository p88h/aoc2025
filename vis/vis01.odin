package vis

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

@(private = "file")
VisFrame :: struct {
	idx:    int, // index of the line being processed
	pos:    int, // current dial position
	rem:    int, // remaining move for the dial before advancing
	steps:  int, // speed of dial movement (=delta to thex frame)
	result: int, // result counter
}

@(private = "file")
VisState :: struct {
	lines:      []string,
	idx:        int, // line to process
	pos:        int, // current dial orientation
	tmp:        int, // remaining move for the dial before advancing
	speed:      int, // speed of dial movement
	tex:        rl.RenderTexture2D,
	res:        int,
	clicks_raw: [12][]u8,
	clicks_wav: [12]rl.Wave,
	clicks_snd: [12]rl.Sound,
	sound_file: os.Handle,
    audio_stream: rl.AudioStream,
}

@(private = "file")
GlobalState :: struct {
    sbuf:   [80000]i16,
    wpos:   uint,
    rpos:   uint,
    delay:  int,
}

@(private = "file")
g_state := GlobalState { delay = 800 } // ~0.02 seconds delay to start

audio_callback :: proc "c" (bufferData: rawptr, frames: c.uint) {
    context = runtime.default_context()
	samples := mem.slice_data_cast([]i16, mem.byte_slice(bufferData, frames * 2))
    if (g_state.delay > 0) {
        fmt.printf("Audio delay: %d/%d frames\n", g_state.delay, frames)
        // wait for it
        for i: uint = 0; i < cast(uint)frames; i += 1 {
            samples[i] = 0
        }
        g_state.delay -= cast(int)(frames)
        return
    }
    context=runtime.default_context()
	num_frames := cast(uint)(frames)
    for i: uint = 0; i < num_frames; i += 1 {
        samples[i] = g_state.sbuf[(g_state.rpos + i) % 80000]
    }
    g_state.rpos = (g_state.rpos + num_frames) % 80000
}

make_noise :: proc(pos: int, amt: int, samples: int) {
    num_notes := abs(amt)
    dir := -1 if amt < 0 else 1
    samples_per_note := samples / num_notes    
    // fill with silence first
    for k : uint = 0; k < cast(uint)samples; k += 1 {
        g_state.sbuf[(g_state.wpos + k) % 80000] = 0
    }
    for n: int = 0; n < num_notes; n += 1 {
        freq : f32 = 340.0 + cast(f32)((pos + n * dir + 100) % 100) * 50.0
        for i: int = 0; i < 100; i += 1 {
            k : uint = cast(uint)(n * samples_per_note + i)
            sample: c.short = 0
            // generate a sine wave with semi-random frequency based on g_pos
            t : f32 = cast(f32)(k) / 44100.0
            sample = cast(c.short)(math.sin(t * freq * 2.0 * math.PI) * 32767.0)
            g_state.sbuf[(g_state.wpos + k) % 80000] = sample
        }
    }    
    g_state.wpos = (g_state.wpos + cast(uint)samples) % 80000
}

clock_pos :: proc(pos: f32, radius: f32, center_x: f32, center_y: f32) -> (f32, f32) {
	angle := pos / 100.0 * 2.0 * math.PI - (math.PI / 2.0)
	x := center_x + radius * math.cos(angle)
	y := center_y + radius * math.sin(angle)
	return x, y
}


// Initialize the example visualization
vis01_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day01.txt")
	vis.lines = strings.split(string(contents), "\n")
	vis.tex = rl.LoadRenderTexture(a.v.width, a.v.height)
	vis.pos = 50
	vis.idx = -1
	vis.tmp = 0
	rl.BeginTextureMode(vis.tex)
	// display the clock face with 100 positions	
	for pos := 0; pos < 100; pos += 1 {
		x, y := clock_pos(
			cast(f32)(pos),
			500.0,
			cast(f32)(a.v.width / 2),
			cast(f32)(a.v.height / 2),
		)
		asciiray_write_at(
			a,
			fmt.aprintf("%02d", pos),
			cast(i32)(x - 10),
			cast(i32)(y - 10),
			rl.WHITE,
		)
	}
	// draw a circle at the center
	rl.DrawCircle(cast(i32)(a.v.width / 2), cast(i32)(a.v.height / 2), 480, rl.DARKGRAY)
	rl.DrawCircleLines(cast(i32)(a.v.width / 2), cast(i32)(a.v.height / 2), 480, rl.WHITE)
	rl.EndTextureMode()

	rl.InitAudioDevice()
    vis.audio_stream = rl.LoadAudioStream(44100, 16, 1)
    rl.SetAudioStreamBufferSizeDefault(44100 / a.v.fps)
    rl.SetAudioStreamCallback(vis.audio_stream, audio_callback)

	// open sound.raw to capture generated sounds for debugging
	vis.sound_file, _ = os.open("sound.raw", os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644)
    rl.PlayAudioStream(vis.audio_stream)
	return vis
}

// Step the example visualization
vis01_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	rl.DrawTextureRec(
		vis.tex.texture,
		rl.Rectangle{0, 0, cast(f32)(vis.tex.texture.width), -cast(f32)(vis.tex.texture.height)},
		rl.Vector2{0, 0},
		rl.WHITE,
	)
	if vis.tmp == 0 {
		vis.idx += 1
		// limit to 200 lines
		if vis.idx >= len(vis.lines) || vis.idx >= 200 {
			return true
		}
		line := vis.lines[vis.idx]
		dir := line[0]
		amt := strconv.parse_int(line[1:]) or_else 0
		switch dir {
		case 'L':
			vis.tmp = -amt
		case 'R':
			vis.tmp = amt
		}
		vis.speed = 1
	}

	// draw a dial at the current position
	x, y := clock_pos(
		cast(f32)(vis.pos),
		440.0,
		cast(f32)(a.v.width / 2),
		cast(f32)(a.v.height / 2),
	)
	rl.DrawCircle(cast(i32)(x), cast(i32)(y), 40, rl.WHITE)

	// add a small triangle inside the dial
	x1, y1 := clock_pos(
		cast(f32)(vis.pos),
		480.0,
		cast(f32)(a.v.width / 2),
		cast(f32)(a.v.height / 2),
	)
	x2, y2 := clock_pos(
		cast(f32)(vis.pos) - 0.2,
		470.0,
		cast(f32)(a.v.width / 2),
		cast(f32)(a.v.height / 2),
	)
	x3, y3 := clock_pos(
		cast(f32)(vis.pos) + 0.2,
		470.0,
		cast(f32)(a.v.width / 2),
		cast(f32)(a.v.height / 2),
	)
	rl.DrawTriangle(rl.Vector2{x1, y1}, rl.Vector2{x2, y2}, rl.Vector2{x3, y3}, rl.DARKGRAY)

	// display all processed lines
	for i: int = 0; i <= vis.idx; i += 1 {
		col := rl.LIME if (i == 0) else rl.BROWN
		asciiray_write_xy(
			a,
			vis.lines[vis.idx - i],
			1 + 6 * cast(i32)(i / 50),
			1 + cast(i32)(i % 50),
			col,
		)
	}

	// display current remaining move
	if (vis.tmp > 0) {
		asciiray_write_xy(a, fmt.aprintf("> %03d >", vis.tmp), 94, 26, rl.WHITE)
	} else {
		asciiray_write_xy(a, fmt.aprintf("< %03d <", -vis.tmp), 94, 26, rl.WHITE)
	}

	asciiray_write_xy(a, fmt.aprintf("R = %03d", vis.res), 94, 28, rl.YELLOW)

	// move the dial towards its target position
	if vis.tmp != 0 {
		step := vis.speed
		if abs(vis.tmp) < step {
			step = abs(vis.tmp)
		}
		// Play sound and write raw data to file (skip 44-byte WAV header)
        samples := (44100 / cast(int)a.v.fps)
        make_noise(vis.pos, vis.speed, samples)
        // write last samples from g_state buffer to file
        buf_start := (g_state.wpos + 80000 - cast(uint)(samples)) % 80000
        if buf_start + cast(uint)(samples) > 80000 {
            // wrap around
            raw_bytes := mem.slice_data_cast([]byte, g_state.sbuf[buf_start:80000])
            os.write(vis.sound_file, raw_bytes)
            second_part := cast(uint)(g_state.wpos % 80000)
            raw_bytes2 := mem.slice_data_cast([]byte, g_state.sbuf[0:second_part])
            os.write(vis.sound_file, raw_bytes2)
        } else {
            raw_bytes := mem.slice_data_cast([]byte, g_state.sbuf[buf_start:buf_start + cast(uint)(samples)])
            os.write(vis.sound_file, raw_bytes)
        }
		if vis.tmp < 0 {
			if vis.pos > 0 && vis.pos <= step {
				vis.res += 1
			}
			vis.pos = (vis.pos - step + 100) % 100
			vis.tmp += step
		} else {
			if vis.pos + step >= 100 {
				vis.res += 1
			}
			vis.pos = (vis.pos + step) % 100
			vis.tmp -= step
		}
		if vis.speed < 11 {
			vis.speed += 1
		}
	}
	return false
}

// Boilerplate handler for the example visualization
VIS01_HANDLER :: Handler {
	init = vis01_init,
	step = vis01_step,
	window = Window{width = 1920, height = 1080, fps = 30, fsize = 20},
}

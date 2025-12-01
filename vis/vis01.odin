package vis

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:os"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

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
}

clock_pos :: proc(pos: f32, radius: f32, center_x: f32, center_y: f32) -> (f32, f32) {
	angle := pos / 100.0 * 2.0 * math.PI - (math.PI / 2.0)
	x := center_x + radius * math.cos(angle)
	y := center_y + radius * math.sin(angle)
	return x, y
}

// generate a wave file in memory, that will contain X 'click' sounds spaced equally throughout the
// sample buffer. Each click is a short burst of white noise.
generate_clicks_wav :: proc(num_clicks: uint, sample_rate: int, duration_secs: f32) -> []u8 {
	wav_header_size: uint = 44
	total_samples := cast(uint)(cast(f32)(sample_rate) * duration_secs)
	data_size := total_samples * 2  // 16-bit = 2 bytes per sample
	buffer := make([]u8, data_size + wav_header_size)
	
	base_header := "RIFF----WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00--------\x02\x00\x10\x00data----"
	for i: uint = 0; i < wav_header_size; i += 1 {
		buffer[i] = base_header[i]
	}
	
	// Write chunk size at offset 4 (file size - 8)
	chunk_size := wav_header_size - 8 + data_size
	bytes_per_sec := sample_rate * 2  // mono, 16-bit
	for i: uint = 0; i < 4; i += 1 {
		buffer[i + 4] = cast(u8)((chunk_size >> (i * 8)) & 0xFF)
		buffer[i + 24] = cast(u8)((sample_rate >> (i * 8)) & 0xFF)
		buffer[i + 28] = cast(u8)((bytes_per_sec >> (i * 8)) & 0xFF)
		buffer[i + 40] = cast(u8)((data_size >> (i * 8)) & 0xFF)
	}

	// Generate 16-bit audio samples
	if num_clicks > 0 {
		samples_per_click := total_samples / num_clicks
		click_length: uint = 30  // samples per click sound
		for click_idx: uint = 0; click_idx < num_clicks; click_idx += 1 {
			start_sample := click_idx * samples_per_click
			for s: uint = 0; s < click_length && (start_sample + s) < total_samples; s += 1 {
				// Generate 16-bit signed white noise sample (-32768 to 32767)
				// Use envelope to avoid clicking at start/end
				envelope := 1.0 - cast(f32)(s) / cast(f32)(click_length)
				noise := cast(i16)(cast(f32)(rand.int31_max(65535) - 32768) * envelope * 0.5)
				
				// Write 16-bit sample (little-endian)
				sample_offset := wav_header_size + (start_sample + s) * 2
				buffer[sample_offset] = cast(u8)(noise & 0xFF)
				buffer[sample_offset + 1] = cast(u8)((noise >> 8) & 0xFF)
			}
		}
	}
	return buffer
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
	for c : uint = 0; c < 12; c += 1 {
		vis.clicks_raw[c] = generate_clicks_wav(c, 44100, 1.0 / cast(f32)(a.v.fps))
		vis.clicks_wav[c] = rl.LoadWaveFromMemory(".wav", raw_data(vis.clicks_raw[c]), cast(i32)len(vis.clicks_raw[c]))
		vis.clicks_snd[c] = rl.LoadSoundFromWave(vis.clicks_wav[c])
	}
	// open sound.raw to capture generated sounds for debugging
	vis.sound_file, _ = os.open("sound.raw", os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644)
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
		rl.PlaySound(vis.clicks_snd[cast(uint)(step)])
		if vis.sound_file != os.INVALID_HANDLE {			
			os.write(vis.sound_file, vis.clicks_raw[cast(uint)(step)][44:]) // skip WAV header
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
	window = Window{width = 1920, height = 1080, fps = 10, fsize = 20},
}

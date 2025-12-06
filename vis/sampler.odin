package vis

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:math"
import "core:mem"
import rl "vendor:raylib"

@(private = "file")
GlobalState :: struct {
	initialized:  bool,
	fbuf:         [80000]i16,
	sbuf:         [80000]i16,
	wpos:         uint,
	rpos:         uint,
	delay:        int,
	frame_len:    int,
	ff_pipe:      FFPipe,
	audio_stream: rl.AudioStream,
}

@(private = "file")
g_state := GlobalState {
	delay = 800,
} // ~0.02 seconds delay to start

@(private = "file")
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
	context = runtime.default_context()
	num_frames := cast(uint)(frames)
	for i: uint = 0; i < num_frames; i += 1 {
		samples[i] = g_state.sbuf[(g_state.rpos + i) % 80000]
	}
	g_state.rpos = (g_state.rpos + num_frames) % 80000
}

// generates multiple (amt) clicky sounds with fequency based on pos (0-100)
// frequency is modulated for each click instance - upwards if amt>0, downwards if amt<0
make_noise :: proc(pos: int, amt: int) {
	samples := g_state.frame_len
	num_notes := abs(amt)
	dir := -1 if amt < 0 else 1
	// fill with silence first
	for k: uint = 0; k < cast(uint)samples; k += 1 {
		g_state.sbuf[(g_state.wpos + k) % 80000] = 0
		g_state.fbuf[k] = 0
	}
	samples_per_note := samples / num_notes if num_notes > 0 else 0
	for n: int = 0; n < num_notes; n += 1 {
		freq: f32 = 340.0 + cast(f32)((pos + n * dir + 100) % 100) * 50.0
		for i: int = 0; i < 100; i += 1 {
			k: uint = cast(uint)(n * samples_per_note + i)
			sample: c.short = 0
			t: f32 = cast(f32)(k) / 48000.0
			sample = cast(c.short)(math.sin(t * freq * 2.0 * math.PI) * 32767.0)
			g_state.sbuf[(g_state.wpos + k) % 80000] = sample
			g_state.fbuf[k] = sample
		}
	}
	g_state.wpos = (g_state.wpos + cast(uint)samples) % 80000
	if g_state.ff_pipe.running {
		raw_bytes := mem.slice_data_cast([]byte, g_state.fbuf[0:g_state.frame_len])
		ffpipe_put(&g_state.ff_pipe, raw_data(raw_bytes), cast(i32)len(raw_bytes))
	}
}

// Convert piano key number to frequency in Hz
piano_keys :: #force_inline proc(key: int) -> f32 {
	return 440.0 * math.pow(2.0, (cast(f32)(key) - 49.0) / 12.0)
}

// Generate a single beep sound at given frequency, volume and duration
// Applies quadratic fade-out to avoid clicks
make_beep :: proc(frequency: f32, volume: f32, duration: f32) {
	samples := g_state.frame_len
	// fill with silence first
	for k: uint = 0; k < cast(uint)samples; k += 1 {
		g_state.sbuf[(g_state.wpos + k) % 80000] = 0
		g_state.fbuf[k] = 0
	}
	// duration is in seconds
	beep_samples := cast(uint)(duration * 48000.0)
	max_volume := 32767.0 * volume
	// fmt.printfln("Generating beep: freq=%.2f Hz, volume=%.2f, duration=%.2f s (%d/%d samples)", frequency, volume, duration, beep_samples, samples)
	for k: uint = 0; k < beep_samples; k += 1 {
		t: f32 = cast(f32)(k) / 48000.0
		pos_relative := (cast(f32)(k) / cast(f32)(beep_samples))
		fade := 1.0 - math.pow(pos_relative, 2)
		sample := cast(c.short)(math.sin(t * frequency * 2.0 * math.PI) * max_volume * fade)
		g_state.sbuf[(g_state.wpos + k) % 80000] = sample
		g_state.fbuf[k] = sample
	}
	g_state.wpos = (g_state.wpos + cast(uint)samples) % 80000
	if g_state.ff_pipe.running {
		raw_bytes := mem.slice_data_cast([]byte, g_state.fbuf[0:g_state.frame_len])
		ffpipe_put(&g_state.ff_pipe, raw_data(raw_bytes), cast(i32)len(raw_bytes))
	}
}

audio_init :: proc(v: ^Viewer) {
	rl.InitAudioDevice()
	g_state.audio_stream = rl.LoadAudioStream(48000, 16, 1)
	rl.SetAudioStreamBufferSizeDefault(48000 / v.fps)
	rl.SetAudioStreamCallback(g_state.audio_stream, audio_callback)
	// open sound.raw to capture generated sounds for debugging
	if v.rec {
		g_state.ff_pipe = ffpipe_init_audio(48000, 1)
	}
	rl.PlayAudioStream(g_state.audio_stream)
	g_state.frame_len = 48000 / int(v.fps)
	g_state.initialized = true
}

audio_finish :: proc() {
	if !g_state.initialized {
		return
	}
	rl.StopAudioStream(g_state.audio_stream)
	rl.UnloadAudioStream(g_state.audio_stream)
	rl.CloseAudioDevice()
	if g_state.ff_pipe.running {
		ffpipe_finish(&g_state.ff_pipe)
		ffpipe_merge("output.mp4")
	}
}

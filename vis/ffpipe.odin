package vis

import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:os"

// Foreign import for popen/pclose
foreign import clib "system:c"

@(default_calling_convention = "c")
foreign clib {
	popen :: proc(command: cstring, type: cstring) -> ^libc.FILE ---
	pclose :: proc(stream: ^libc.FILE) -> c.int ---
}

// FFPipe handles piping video frames to ffmpeg for recording
FFPipe :: struct {
	pipe:    ^libc.FILE,
	running: bool,
}

// Initialize FFPipe with video parameters
ffpipe_init :: proc(width, height, fps: i32, scale: f32) -> (ff: FFPipe) {
	sw := i32(f32(width) * scale)
	sh := i32(f32(height) * scale)

	// Delete existing output file
	os.remove("out.mp4")

	// Build ffmpeg command
	cmd := fmt.ctprintf(
		"ffmpeg -loglevel quiet -f rawvideo -pix_fmt rgba -s %dx%d -r %d -i - -s %dx%d out.mp4",
		sw,
		sh,
		fps,
		width,
		height,
	)

	ff.pipe = popen(cmd, "w")
	if ff.pipe == nil {
		fmt.eprintln("Error running ffmpeg, recording disabled")
		ff.running = false
		return ff
	}

	ff.running = true
	return ff
}

// Write frame data to ffmpeg
ffpipe_put :: proc(ff: ^FFPipe, data: rawptr, size: i32) {
	if ff.running && ff.pipe != nil {
		written := libc.fwrite(data, 1, uint(size), ff.pipe)
		if written != uint(size) {
			fmt.eprintln("Error writing to ffmpeg, recording stopped")
			ffpipe_finish(ff)
		}
	}
}

// Finish recording and wait for ffmpeg to complete
ffpipe_finish :: proc(ff: ^FFPipe) {
	if ff.running && ff.pipe != nil {
		ff.running = false
		libc.fflush(ff.pipe)
		result := pclose(ff.pipe)
		if result != 0 {
			fmt.eprintln("ffmpeg exited with code:", result)
		}
		ff.pipe = nil
	}
}

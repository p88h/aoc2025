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

ffpipe_init_video :: proc(width, height, fps: i32, scale: f32) -> (ff: FFPipe) {
	sw := i32(f32(width) * scale)
	sh := i32(f32(height) * scale)
	// Delete existing output file
	os.remove("out_video.m4v")
	cmd := fmt.ctprintf(
		"ffmpeg -loglevel quiet -f rawvideo -pix_fmt rgba -s %dx%d -r %d -i - -s %dx%d out_video.m4v",
		sw,
		sh,
		fps,
		width,
		height,
	)
    return ffpipe_init(cmd)
}

ffpipe_init_audio :: proc(frequency, channels: i32) -> (ff: FFPipe) {
	// Delete existing output file
	os.remove("out_audio.m4a")
	cmd := fmt.ctprintf(
		"ffmpeg -loglevel quiet -f s16le -ar %d -ac %d -i - out_audio.m4a",
		frequency,
		channels,
	)
    return ffpipe_init(cmd)
}

ffpipe_merge :: proc(filename: string) {
	// Merge audio and video into final output
	os.remove(filename)
	cmd := fmt.ctprintf("ffmpeg -loglevel quiet -i out_video.m4v -i out_audio.m4a -c:v copy -c:a copy %s", filename)
	exit_code := libc.system(cmd)
	if exit_code != 0 {
		fmt.eprintln("Error merging audio and video, exit code:", exit_code)
	} else {
		fmt.println("Merged audio and video into", filename)
        os.remove("out_video.m4v")
        os.remove("out_audio.m4a")
	}
}

// Initialize FFPipe with video parameters
ffpipe_init :: proc(cmd: cstring) -> (ff: FFPipe) {
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

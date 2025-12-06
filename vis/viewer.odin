package vis

import "core:c"
import rl "vendor:raylib"

// Viewer handles window management and rendering loop
Viewer :: struct {
	width:  i32,
	height: i32,
	fps:    i32,
	title:  cstring,
	rec:    bool,
	ff:     FFPipe,
}

// Initialize the viewer with window parameters
viewer_init :: proc(w, h, fps: i32, title: cstring, rec: bool) -> Viewer {
	rl.SetConfigFlags({.MSAA_4X_HINT})
	rl.InitWindow(w, h, title)

	return Viewer{width = w, height = h, fps = fps, title = title, rec = rec}
}

// Viewer render callback type
ViewerRenderProc :: #type proc(idx: uint, ctx: rawptr) -> bool

// Run the main rendering loop
viewer_loop :: proc(v: ^Viewer, render: ViewerRenderProc, ctx: rawptr) {
	cnt: uint = 0
	done: bool = false
	defer rl.CloseWindow()

	rl.SetTargetFPS(v.fps)
	scale := rl.GetWindowScaleDPI().x

	if v.rec {
		v.ff = ffpipe_init_video(v.width, v.height, v.fps, scale)
	}

	for !rl.WindowShouldClose() && !done {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		done = render(cnt, ctx)
		cnt += 1
		rl.EndDrawing()

		if v.rec {
			img := rl.LoadImageFromScreen()
			ffpipe_put(&v.ff, img.data, img.height * img.width * 4)
			rl.MemFree(img.data)
		}
	}

	if v.rec {
		ffpipe_finish(&v.ff)
        audio_finish()
	}
}

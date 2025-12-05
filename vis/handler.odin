package vis

import "core:fmt"
import rl "vendor:raylib"

// Window configuration
Window :: struct {
	width:  i32,
	height: i32,
	fps:    i32,
	fsize:  i32,
}

// Default window configuration
DEFAULT_WINDOW :: Window {
	width  = 1920,
	height = 1080,
	fps    = 60,
	fsize  = 16,
}

// Handler init function type - called once to set up visualization state
HandlerInitProc :: #type proc(a: ^ASCIIRay) -> rawptr

// Handler step function type - called each frame, returns true when done
HandlerStepProc :: #type proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool

// Handler structure for visualization dispatch
Handler :: struct {
	window: Window,
	init:   HandlerInitProc,
	step:   HandlerStepProc,
}

// Internal context for the render loop
@(private = "file")
RunContext :: struct {
	ascii_ray:   ASCIIRay,
	viewer:      Viewer,
	handler:     Handler,
	handler_ctx: rawptr,
}

// Internal render callback that bridges to the handler's step function
@(private = "file")
render_callback :: proc(idx: uint, ptr: rawptr) -> bool {
	ctx := cast(^RunContext)ptr
	return ctx.handler.step(ctx.handler_ctx, &ctx.ascii_ray, idx)
}

// Run a handler with optional recording
handler_run :: proc(h: Handler, rec: bool) {
	win := h.window
	viewer := viewer_init(win.width, win.height, win.fps, "Advent Of Code", rec)
	ctx := RunContext {
		ascii_ray   = asciiray_init(&viewer, win.fsize),
		viewer      = viewer,
		handler     = h,
		handler_ctx = nil,
	}
	// ctx.ascii_ray.v = &ctx.viewer
	ctx.handler_ctx = h.init(&ctx.ascii_ray)
	viewer_loop(&ctx.viewer, render_callback, &ctx)
}

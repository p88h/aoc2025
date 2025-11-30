package vis

import "core:fmt"
import "core:strings"
import "core:os"
import "core:c/libc"
import rl "vendor:raylib"

// ASCIIRay handles text rendering using raylib fonts
ASCIIRay :: struct {
    font:  rl.Font,
    fsize: f32,
    cx:    f32,
    cy:    f32,
    v:     ^Viewer,
}

FONT_NAME :: "Inconsolata-SemiBold.ttf"
FONT_FILE :: "resources/" + FONT_NAME
FONT_URI  :: "https://github.com/googlefonts/Inconsolata/raw/main/fonts/ttf/" + FONT_NAME

// Initialize ASCIIRay with window and font parameters
asciiray_init :: proc(viewer: ^Viewer, size: i32) -> ASCIIRay {
    // Check if font file exists, download if not
    if !os.exists(FONT_FILE) {
        fmt.println("Font file not found, attempting to download:", FONT_FILE)
        cmd := fmt.ctprintf("mkdir -p resources && curl -sL -o %s %s", FONT_FILE, FONT_URI)
        result := libc.system(cmd)
        if result != 0 {
            fmt.eprintln("Failed to download font file")
        }
    }
    
    a: ASCIIRay
    a.v = viewer
    a.font = rl.LoadFontEx(FONT_FILE, size, nil, 256)
    fmt.println("Font texture id:", a.font.texture.id)
    a.fsize = f32(size)
    a.cy = 0
    a.cx = 0
    return a
}

// Write text with custom color at current position
asciiray_write :: proc(a: ^ASCIIRay, msg: string, color: rl.Color) {
    msg_len := len(msg)
    // Find null terminator if present
    if null_idx := strings.index_byte(msg, 0); null_idx >= 0 {
        msg_len = null_idx
    }    
    msg_width := f32(msg_len) * (a.fsize / 2)    
    // Create null-terminated string for raylib
    cmsg := strings.clone_to_cstring(msg[:msg_len], context.temp_allocator)
    rl.DrawTextEx(a.font, cmsg, {a.cx, a.cy}, a.fsize, 1, color)
    a.cx += msg_width
}

// Write text with newline
asciiray_writeln :: proc(a: ^ASCIIRay, msg: string, color: rl.Color) {
    asciiray_write(a, msg, color)
    a.cx = 0
    a.cy += a.fsize
    maxy := f32(a.v.height)
    if a.cy > maxy {
        a.cy -= maxy
    }
}

// Write text at specific character position
asciiray_write_xy :: proc(a: ^ASCIIRay, msg: string, x, y: i32, color: rl.Color) {
    a.cx = f32(x) * a.fsize / 2
    a.cy = f32(y) * a.fsize
    asciiray_write(a, msg, color)
}

// Write text at specific pixel position
asciiray_write_at :: proc(a: ^ASCIIRay, msg: string, x, y: i32, color: rl.Color) {
    a.cx = f32(x)
    a.cy = f32(y)
    asciiray_write(a, msg, color)
}

// Reset cursor to home position
asciiray_home :: proc(a: ^ASCIIRay) {
    a.cx = 0
    a.cy = 0
}

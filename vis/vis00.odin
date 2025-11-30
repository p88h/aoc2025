package vis

import "core:os"
import "core:strings"
import rl "vendor:raylib"

@(private="file")
VisState :: struct {
    lines: []string,
    posx:  i32,
    posy:  i32,
    dx:    i32,
    dy:    i32,
}

// Initialize the example visualization
vis00_init :: proc(a: ^ASCIIRay) -> rawptr {
    vis := new(VisState)
    
    // Try to load day01 input
    data, ok := os.read_entire_file("inputs/day01.txt")
    if ok {
        content := string(data)
        vis.lines = strings.split_lines(content)
    } else {
        vis.lines = []string{"Hello, World! This is a test visualization."}
    }
    
    vis.posx = 0
    vis.posy = 0
    vis.dx = 1
    vis.dy = 1
    return vis
}

// Step the example visualization
vis00_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
    vis := cast(^VisState)ctx
    
    if idx > 100 {
        return true
    }
    
    if len(vis.lines) > 0 {
        asciiray_write_xy(a, vis.lines[0], vis.posx, vis.posy, rl.RAYWHITE)
    }
    
    vis.posx += vis.dx
    vis.posy += vis.dy
    
    if vis.posx < 0 || vis.posx >= 120 {
        vis.dx = -vis.dx
        vis.posx += vis.dx
    }
    if vis.posy < 0 || vis.posy >= 33 {
        vis.dy = -vis.dy
        vis.posy += vis.dy
    }
    
    return false
}

// Boilerplate handler for the example visualization
VIS00_HANDLER :: Handler{
    init   = vis00_init,
    step   = vis00_step,
    window = Window{
        width  = 1920,
        height = 1080,
        fps    = 30,
        fsize  = 32,
    },
}

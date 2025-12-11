package vis

import "core:crypto/legacy/keccak"
import sol "../src"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	lines: []string,
	data:  ^sol.Day11Data,
    counters: [1024]int,
    active: [dynamic]i16,
    next: [dynamic]i16,
    posx: [1024]int,
    posy: [1024]int,
    color: [1024]rl.Color,
    dac: i16,
    fft: i16,
    out: i16,
    step: int,
}

@(private = "file")
encode :: proc(s: string) -> int {
	id := 0
	for c in s do id = id * 26 + (int(c) - int('a'))
	return id
}

// Initialize the example visualization
vis11_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day11.txt")
	vis.data = cast(^sol.Day11Data)sol.day11(string(contents)).data
    // count incoming edges for each node
    for i in 0 ..= vis.data.size {
        for j in vis.data.graph[i] {
            vis.counters[j] += 1
        }
        vis.color[i] = rl.DARKGRAY
    }
    vis.color[vis.data.codes[encode("svr")]] = rl.YELLOW
    vis.dac = vis.data.codes[encode("dac")]
    vis.color[vis.dac] = rl.RED
    vis.color[vis.data.codes[encode("you")]] = rl.MAGENTA
    vis.fft = vis.data.codes[encode("fft")]
    vis.color[vis.fft] = rl.BLUE
    vis.out = vis.data.codes[encode("out")]
    vis.color[vis.out] = rl.GREEN
    // find all nodes with zero incoming edges
    for i in 0 ..= vis.data.size {
        if vis.counters[i] == 0 && len(vis.data.graph[i]) > 0 {
            append(&vis.next, i16(i))
            vis.data.paths[i] = 1
        }
    }
	vis.step = 0
	return vis
}

@(private = "file")
SCALE :: 100

@(private = "file")
exhaust :: proc (vis: ^VisState, node: i16) {
    data := vis.data
    vis.counters[node] = -1
    for neighbor in data.graph[node] {
        vis.counters[neighbor] -= 1
        if vis.counters[neighbor] == 0 {    
            exhaust(vis, neighbor)
        }
    }
}

// expand from active -> next
@(private = "file")
expand :: proc(vis: ^VisState) {
    special := i16(0)
    for node in vis.active {
        for neighbor in vis.data.graph[node] {
            vis.counters[neighbor] -= 1
            vis.data.paths[neighbor] += vis.data.paths[node]
            if vis.counters[neighbor] == 0 {
                append(&vis.next, i16(neighbor))
                vis.counters[neighbor] = -1
                if i16(neighbor) == vis.dac || i16(neighbor) == vis.fft {
                    special = i16(neighbor)
                }
            }
        }
    }
    clear(&vis.active)
    if special != 0 {
        for i in vis.next {
            if i != special do exhaust(vis, i)
        }
        clear(&vis.next)
        append(&vis.next, special)
    }
}

vis11_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
    // draw all nodes with posx / posy
    for i in 0 ..= vis.data.size {
        if vis.posx[i] != 0 {
            x, y := i32(vis.posx[i]), i32(vis.posy[i])
            // draw edges
            for neighbor in vis.data.graph[i] {
                nx, ny := i32(vis.posx[neighbor]), i32(vis.posy[neighbor])
                if nx == 0 do continue
                // make a darkish yellow 'cable' color
                col := rl.Color{200, 200, 50, 255}
                rl.DrawLineEx({f32(x), f32(y)}, {f32(nx), f32(ny)}, 3.0, col)
            }
        }
    }
    for i in 0 ..= vis.data.size {
        if vis.posx[i] != 0 {
            x, y := i32(vis.posx[i]), i32(vis.posy[i])
            rl.DrawCircle(x, y, 8, vis.color[i])
        }
    }
    // pop one of the next list to active
    if len(vis.next) > 0 {
        tot := len(vis.next) + len(vis.active)
        i := pop(&vis.next)
        append(&vis.active, i)
        vis.posx[i] = 30 + vis.step * 49
        vis.posy[i] = (1000 / (tot + 1)) * len(vis.active)
    } else {
        // if next is empty, expand
        expand(vis)
        vis.step += 1
    }
    legends := [3]i16{ vis.fft, vis.dac, vis.out }
    ofs := 200
    for i in legends {
        // draw circle legend at bottom if count of paths to that node is known
        if vis.data.paths[i] > 0 {
            x := i32(ofs)
            y := i32(1000)
            rl.DrawCircle(x, y, 12, vis.color[i])
            label := fmt.tprintf("%d", vis.data.paths[i])
            asciiray_write_at(a, label, x + 12, y - 12, rl.WHITE)
            ofs += 240
        }

    }

    return false
}

// Boilerplate handler for the example visualization
VIS11 :: Handler {
	init = vis11_init,
	step = vis11_step,
	window = Window{width = 1920, height = 1080, fps = 15, fsize = 24},
}

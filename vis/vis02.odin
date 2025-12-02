package vis

import "core:fmt"
import "core:os"
import rl "vendor:raylib"
import sol "../src"

@(private = "file")
VisState :: struct {
	input: ^sol.Day2Input,
    active_ranges: [16]int,
    range_idx: [16]int,
    range_len: [16]int,
    numbers: [16][dynamic]int,
    counter: [16]int,
    next_range: int,
    help: [10][5][2]int,
    periodic: [100000]bool,
}

MAX_ROWS := 50

// Initialize the example visualization
vis02_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day02.txt")
	vis.input = cast(^sol.Day2Input)sol.day02(string(contents)).data
    vis.help = sol.day2_make_helper_table()
    vis.periodic = sol.day2_make_periodic_table()
    for i: int = 0; i < 16; i += 1 {
        vis.active_ranges[i] = -1
        vis.counter[i] = MAX_ROWS
    }
    vis.next_range = 0
	return vis
}

// Step the example visualization
vis02_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	if idx > 320 {
		return true
	}
    xpos : i32 = 0
    add_limit := 1
    for i in 0..<16 {
        if add_limit > 0 && vis.counter[i] >= MAX_ROWS && vis.next_range < len(vis.input.ranges) {
            vis.active_ranges[i] = vis.next_range
            vis.range_idx[i] = 0
            vis.range_len[i] = 0
            vis.counter[i] = 0
            vis.next_range += 1
            add_limit -= 1
            vis.numbers[i] = make([dynamic]int)
            b := 1
            // precompute all numbers for this range
            range := vis.input.ranges[vis.active_ranges[i]]
            for j: int = 1; j <= range.len/2; j += 1 {
                if range.len % j != 0 {
                    continue
                }
                rep := range.len / j
                bbase := vis.help[range.len-1][j-1][0]
                mult := vis.help[range.len-1][j-1][1]
                pat_start := range.start / bbase
                pat_end := range.end / bbase
                
                for p := pat_start; p * mult <= range.end; p += 1 {
                    val := p * mult
                    if val < range.start {
                        continue
                    }
                    // Check if this pattern has a smaller primitive period by checking if p itself is periodic.
                    if vis.periodic[p] {
                        continue
                    }
                    append(&vis.numbers[i], val)
                }
            }
        }
        if vis.counter[i] >= MAX_ROWS {
            continue
        }
        xpos := cast(i32)(i * 12)
        range := vis.input.ranges[vis.active_ranges[i]]
		asciiray_write_xy(a, fmt.aprintf("%d", range.start), xpos, 0, rl.BEIGE)
        asciiray_write_xy(a, fmt.aprintf("%d", range.end), xpos, 1, rl.BEIGE)        
        // shift range window if possible
        if vis.range_idx[i] + vis.range_len[i] < len(vis.numbers[i]) {
            if vis.range_len[i] < MAX_ROWS {
                vis.range_len[i] += 1
            } else {
                vis.range_idx[i] += 1
            }
        } else {            
            vis.counter[i] += 1
            if vis.range_len[i] > 0 {
                vis.range_len[i] -= 1
                vis.range_idx[i] += 1
            }
        }
        ypos : i32 = 2
        for k in vis.numbers[i][vis.range_idx[i]:vis.range_idx[i]+vis.range_len[i]] {
            numstr := fmt.aprintf("%d", k)
            // figure out the periodicity from string
            for p in 1..=len(numstr)/2 {
                if len(numstr) % p != 0 {
                    continue
                }
                repeated := true
                for k in 0..<len(numstr) {
                    if numstr[k] != numstr[k % p] {
                        repeated = false
                        break
                    }
                }
                if repeated {
                    num1 := string(numstr[0:p])
                    num2 := string(numstr[p:len(numstr)])
                    asciiray_write_xy(a, num1, xpos, ypos, rl.YELLOW)
                    asciiray_write_xy(a, num2, xpos + cast(i32)p, ypos, rl.LIME)
                    break
                }
            }
            ypos += 1
        }
    }
	return false
}

// Boilerplate handler for the example visualization
VIS02_HANDLER :: Handler {
	init = vis02_init,
	step = vis02_step,
	window = Window{width = 1920, height = 1080, fps = 10, fsize = 20},
}

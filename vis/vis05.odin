package vis

import sol "../src"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	nums:           []int,
	ranges:         int,
	phase:          int,
	pixels:         [1920 * 1080]int,
	pixel_estimate: int,
	error_margin:   int,
}

// Initialize the example visualization
vis05_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day05.txt")
	vis.nums = sol.fast_parse_all_integers(string(contents))[:]
	vis.phase = 0
    audio_init(a.v)
	return vis
}

SCALE :: int(math.max(i64) / (1920 * 1080)) / 16000

// Step the example visualization
vis05_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	if idx >= len(vis.nums) + 120 {
		return true
	}
	if vis.phase == 0 {
		if vis.nums[idx] == 0 {
			vis.phase += 1
		} else {
			vis.ranges = int(idx / 2) + 1
		}
		vis.pixels = 0
		vis.pixel_estimate = 0
		vis.error_margin = 0
		for r in 0 ..< vis.ranges {
			start := vis.nums[r * 2] / SCALE
			end := vis.nums[r * 2 + 1] / SCALE
			for p in start + 1 ..< end {
				vis.pixel_estimate -= vis.pixels[p]
				vis.pixels[p] = SCALE
				vis.pixel_estimate += SCALE
			}
			if (start == end) {
				partial := vis.nums[r * 2 + 1] - vis.nums[r * 2]
				vis.pixel_estimate -= vis.pixels[start]
				vis.pixels[start] = max(vis.pixels[start], partial)
				vis.error_margin += vis.pixels[start] - min(vis.pixels[start], partial)
				vis.pixel_estimate += vis.pixels[start]
				continue
			}
			if vis.pixels[start] < SCALE {
				partial := SCALE - (vis.nums[r * 2] % SCALE)
				vis.pixel_estimate -= vis.pixels[start]
				vis.pixels[start] = max(vis.pixels[start], partial)
				vis.error_margin += vis.pixels[start] - min(vis.pixels[start], partial)
				vis.pixel_estimate += vis.pixels[start]
			}
			if vis.pixels[end] < SCALE {
				partial := vis.nums[r * 2 + 1] % SCALE
				vis.pixel_estimate -= vis.pixels[end]
				vis.pixels[end] = max(vis.pixels[end], partial)
				vis.error_margin += vis.pixels[end] - min(vis.pixels[end], partial)
				vis.pixel_estimate += vis.pixels[end]
			}
		}
	}
	// display ranges so far
    last_row := 0
	for r in 0 ..< vis.ranges {
		start := vis.nums[r * 2] / SCALE
		end := vis.nums[r * 2 + 1] / SCALE
		col := rl.Color{255, 255, 255, 80}
		if start / 1920 == end / 1920 {
			rl.DrawLine(
				i32(start % 1920),
				i32(start / 1920),
				i32(end % 1920),
				i32(end / 1920),
				col,
			)
			continue
		} else {
			// the range is scaled down 1::SCALE but it can still be very large / multiple lines.
			rl.DrawLine(i32(start % 1920), i32(start / 1920), i32(1920), i32(start / 1920), col)
			// rectangle in the middle
			rl.DrawRectangle(
				i32(0),
				i32(start / 1920 + 1),
				i32(1920),
				i32(end / 1920 - start / 1920 - 1),
				col,
			)
			// last line
			rl.DrawLine(i32(0), i32(end / 1920), i32(end % 1920), i32(end / 1920), col)
		}
        last_row = end / 1920
	}
	match := 0
	no_match := 0
	if vis.phase == 1 {
		// display samples
		sample_idx := vis.ranges * 2
        last_match := false
		for sidx in sample_idx ..< min(int(idx), len(vis.nums)) {
			sample := vis.nums[sidx] / SCALE
			if vis.pixels[sample] > 0 {
				rl.DrawCircle(i32(sample % 1920), i32(sample / 1920), 2, rl.GREEN)
				match += 1
                last_row = sample / 1920
			} else {
				rl.DrawCircle(i32(sample % 1920), i32(sample / 1920), 2, rl.RED)
				no_match += 1
                last_row = sample / 1920
			}
			rl.DrawCircle(i32(sample % 1920), i32(sample / 1920), 1, rl.BROWN)
		}
        if last_match {
            make_beep(piano_keys(last_row/10), 1.0, 0.016)
        } else {
            make_beep(piano_keys(last_row/10), 0.5, 0.008)
        }
	} else {
        make_beep(piano_keys(last_row/10), 0.75, 0.012)
    }
	asciiray_write_xy(a, fmt.tprintf("Scale: 1:%d", SCALE), 1, 0, rl.YELLOW)
	// asciiray_write_xy(a, fmt.tprintf("Pixel count: %d", vis.pixel_count), 1, 1, rl.YELLOW)
	asciiray_write_xy(
		a,
		fmt.tprintf("Pixel range estimate: %d", vis.pixel_estimate),
		1,
		1,
		rl.YELLOW,
	)
	asciiray_write_xy(a, fmt.tprintf("Error margin +- %d", vis.error_margin), 1, 2, rl.YELLOW)
	if (match + no_match) > 0 {
		asciiray_write_xy(a, fmt.tprintf("Hits: %d", match), 1, 3, rl.YELLOW)
		asciiray_write_xy(a, fmt.tprintf("Misses: %d", no_match), 1, 4, rl.YELLOW)
	}
	return false
}

// Boilerplate handler for the example visualization
VIS05 :: Handler {
	init = vis05_init,
	step = vis05_step,
	window = Window{width = 1920, height = 1080, fps = 60, fsize = 24},
}

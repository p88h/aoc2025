package vis

import sol "../src"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"

@(private = "file")
VisState :: struct {
	contents:    []byte,
	width:       int,
	height:      int,
	memory:      int,
	value:       int,
	accumulator: int,
	speed:       int,
	pos:         int,
	px:          int,
	py:          int,
	pa:          int,
    delay:       int,
}

// Initialize the example visualization
vis06_init :: proc(a: ^ASCIIRay) -> rawptr {
	vis := new(VisState)
	contents, ok := os.read_entire_file("inputs/day06.txt")
	vis.contents = contents
	for i: int = 0; i < len(vis.contents); i += 1 {
		if vis.contents[i] == '\n' {
			vis.width = i + 1
			for j := i; j < len(vis.contents); j += vis.width {
				vis.contents[j] = ' '
			}
			break
		}
	}
	vis.height = len(vis.contents) / vis.width
	ofs := (vis.height - 1) * vis.width
	fmt.println("Width: ", vis.width, " Height: ", vis.height)
	last: byte = ' '
	for i := 0; i < vis.width; i += 1 {
		if vis.contents[ofs + i] == ' ' {
			vis.contents[ofs + i] = last
		} else {
			last = vis.contents[ofs + i]
			if i > 0 {
				vis.contents[ofs + i - 1] = 'C'
				vis.contents[ofs + i - 1 - 2 * vis.width] = 'M'
			}
		}
	}
	vis.contents[len(vis.contents) - 2 * vis.width - 1] = 'M'
	vis.contents[len(vis.contents) - 1] = 'R'
	fmt.println("Contents: ", string(vis.contents))
	vis.accumulator = -1
	vis.speed = 10
	vis.pos = 0
	return vis
}

CALCULATOR_LAYOUT: [4]string = {" 7 8 9 + ", " 4 5 6 - ", " 1 2 3 / ", " 0 M R * "}

find_digit_pos :: proc(ch: byte) -> (int, int) {
	for y: int = 0; y < len(CALCULATOR_LAYOUT); y += 1 {
		for x: int = 0; x < len(CALCULATOR_LAYOUT[y]); x += 1 {
			if CALCULATOR_LAYOUT[y][x] == ch {
				return x, y
			}
		}
	}
	return -1, -1
}
// Step the example visualization
vis06_step :: proc(ctx: rawptr, a: ^ASCIIRay, idx: uint) -> bool {
	vis := cast(^VisState)ctx
	rl.DrawRectangle(0, 0, 360, 640, rl.Color{40, 40, 40, 255})
	// display calculator grid
	for y: int = 0; y < len(CALCULATOR_LAYOUT); y += 1 {
		for x: int = 0; x < len(CALCULATOR_LAYOUT[y]); x += 1 {
			ch := CALCULATOR_LAYOUT[y][x]
			if ch == ' ' {
				continue
			}
			asciiray_write_at(
				a,
				string([]byte{ch}),
				cast(i32)(x * 40),
				cast(i32)(y * 48) + 4,
				rl.WHITE,
			)
			// border around buttons
			rl.DrawRectangleLines(cast(i32)(x * 40) - 24, cast(i32)(y * 48), 64, 40, rl.GRAY)
		}
	}
	label := "NORTH POLE INSTRUMENTS"
	for i: int = 0; i < len(label); i += 1 {
		cmsg := strings.clone_to_cstring(label[i:i + 1], context.temp_allocator)
		rl.DrawTextEx(
			a.font,
			cmsg,
			{cast(f32)(335), cast(f32)(i * 16) + 4},
			a.fsize / 2,
			1,
			rl.LIME,
		)
	}
	// display calculator 'screen'
	rl.DrawRectangle(16, 200, 300, 348, rl.BLACK)
	rl.DrawRectangleLines(16, 200, 300, 348, rl.GREEN)
	rl.DrawRectangleLines(17, 201, 298, 346, rl.GREEN)
	// display solar cells below the screen
	for i: int = 0; i < 5; i += 1 {
		rl.DrawRectangle(cast(i32)(40 + i * 56), 560, 48, 68, rl.DARKGRAY)
		for j: int = 0; j < 4; j += 1 {
			rl.DrawRectangle(cast(i32)(42 + i * 56), cast(i32)(562 + j * 16), 44, 15, rl.BLACK)
		}
	}
	// display pulsing green power indicator in the bottom left corner
	rl.DrawCircle(20, 610, 12, rl.DARKGREEN)
	rl.DrawCircle(
		20,
		610,
		10,
		rl.Color{0, 255, 0, cast(u8)(128 + 127 * math.sin(cast(f32)(idx) * 0.5))},
	)
	// display current value and accumulator vertically
	val_str := fmt.aprintf("%d", vis.value)
	acc_str := fmt.aprintf("%d", vis.accumulator)
	mem_str := fmt.aprintf("%d", vis.memory)
	for i: int = 0; i < len(val_str); i += 1 {
		asciiray_write_at(
			a,
			val_str[i:i + 1],
			cast(i32)(20),
			cast(i32)(200 + i * 32) + 4,
			rl.YELLOW,
		)
	}
	if vis.accumulator != -1 {
		for i: int = 0; i < len(acc_str); i += 1 {
			asciiray_write_at(
				a,
				acc_str[i:i + 1],
				cast(i32)(100),
				cast(i32)(200 + i * 32) + 4,
				rl.ORANGE,
			)
		}
	}
	if vis.memory != 0 {
		for i: int = 0; i < len(mem_str); i += 1 {
			asciiray_write_at(
				a,
				mem_str[i:i + 1],
				cast(i32)(200),
				cast(i32)(200 + i * 32) + 4,
				rl.RED,
			)
		}
	}
    // highlight previously pressed button fading out
    if vis.pa > 0 {
        rl.DrawRectangle(
            cast(i32)(vis.px * 40) - 24,
            cast(i32)(vis.py * 48),
            64,
            40,
            rl.Color({0, 255, 255, cast(u8)(vis.pa)}),
        )
        vis.pa -= 20
    }
	if idx % cast(uint)(vis.speed) != 0 {
		return false
	}
	if vis.pos >= len(vis.contents) {
        if vis.delay == 20 {
            return true
        }
        vis.delay += 1
		return false
	}
	// process next input character in vertical order fromm contents
	col := int(vis.pos) / vis.height
	row := int(vis.pos) % vis.height
	ch := vis.contents[row * vis.width + col]
	vis.pos += 1
	if ch == ' ' {
		return false
	}
	// increase speed every 10th keypress
	if vis.speed > 1 && idx % cast(uint)(vis.speed * 10) == 0 {
		vis.speed -= 1
	}
	x, y := find_digit_pos(ch)
	if x >= 0 && y >= 0 {
		// highlight button pressed
		rl.DrawRectangle(
			cast(i32)(x * 40) - 24,
			cast(i32)(y * 48),
			64,
			40,
			rl.Color({0, 255, 255, 100}),
		)
		vis.px = x
		vis.py = y
		vis.pa = 100
		// process digit
		if ch >= '0' && ch <= '9' {
			vis.value = vis.value * 10 + int(ch - '0')
		} else if ch == 'M' {
			vis.memory += vis.accumulator
			vis.accumulator = -1
			vis.value = 0
		} else if ch == 'R' {
			vis.accumulator = vis.memory
			vis.memory = 0
			vis.value = 0
		} else if ch == '+' {
			if vis.accumulator == -1 {
				vis.accumulator = 0
			}
			vis.accumulator += vis.value
			vis.value = 0
		} else if ch == '*' {
			if vis.accumulator == -1 {
				vis.accumulator = 1
			}
			vis.accumulator *= vis.value
			vis.value = 0
		}
	}
	return false
}

// Boilerplate handler for the example visualization
VIS06 :: Handler {
	init = vis06_init,
	step = vis06_step,
	window = Window{width = 360, height = 640, fps = 20, fsize = 32},
}

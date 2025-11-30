package vis

import "core:fmt"
import "core:os"
import "core:strconv"

// All available visualizations
ALL_HANDLERS :: []Handler{VIS00_HANDLER}

// Vis main entry point
main :: proc() {
	args := os.args
	ap: uint = 1
	rec := false
	day := 0

	if len(args) > int(ap) && args[ap] == "rec" {
		fmt.println("Recording mode on")
		rec = true
		ap += 1
	}

	if len(args) > int(ap) {
		// Parse day number
		day, ok := strconv.parse_int(args[ap])
		if !ok {
			fmt.println("Invalid day number")
			return
		}
	}

	handlers := ALL_HANDLERS
	if day >= len(handlers) {
		day = len(handlers) - 1
	}

	handler_run(handlers[day], rec)
}

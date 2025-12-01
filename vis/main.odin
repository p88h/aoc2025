package vis

import "core:fmt"
import "core:os"
import "core:strconv"

// All available visualizations
ALL_HANDLERS :: [?]Handler{
    VIS00_HANDLER, VIS01_HANDLER
}

// Vis main entry point
main :: proc() {
	args := os.args
	rec := false
	day := 0
	ok := false

    for ap: int = 1; ap < len(args); ap += 1 {
    	if args[ap] == "rec" {
	    	fmt.println("Recording mode on")
		    rec = true
            continue
	    }
		day, ok = strconv.parse_int(args[ap])
		if !ok {
			fmt.println("Invalid day number")
			return
		}        
    }

	handlers := ALL_HANDLERS
	if day >= len(handlers) {
		day = len(handlers) - 1
	}
    fmt.printf("Running visualization for day %d\n", day)

	handler_run(handlers[day], rec)
}

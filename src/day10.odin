package main

import "core:strings"
import "core:testing"

@(private = "file")
MachineConfig :: struct {
	mask:       u16,
	buttons:    []u16,
	button_mat: [][]i32, // Button matrix B (each row is a button's coefficients)
	joltage:    []i32,   // Target joltage vector J
    res1:       int,
	res2:       int,
}

Day10Data :: struct {
	lines: []MachineConfig,
}


day10 :: proc(contents: string) -> Solution {
	data := new(Day10Data)
	lines := split_lines(contents)
	data.lines = make([]MachineConfig, len(lines))
	for line, i in lines {
		parts := strings.split(line, " ")
		mask_str := parts[0][1:len(parts[0]) - 1]
		for k in 0 ..< len(mask_str) {
			if mask_str[k] == '#' {
				data.lines[i].mask |= (1 << u16(k))
			}
		}

		// Parse joltage to determine number of columns (positions)
		joltage_str := parts[len(parts) - 1]
		joltages := fast_parse_all_integers(joltage_str[1:len(joltage_str) - 1])
		ncols := len(joltages) // Number of positions (joltage values)
		data.lines[i].joltage = make([]i32, ncols)
		for val, pos in joltages {
			data.lines[i].joltage[pos] = i32(val)
		}

		// Parse buttons - number of rows (unknowns to solve for)
		nrows := len(parts) - 2
		data.lines[i].buttons = make([]u16, nrows)
		
		// Create matrix: rows = buttons, cols = positions
		// B[button][pos] = 1 if button affects position pos
		data.lines[i].button_mat = make([][]i32, nrows)
		for row in 0 ..< nrows {
			data.lines[i].button_mat[row] = make([]i32, ncols)
		}
		
		for j in 1 ..< len(parts) - 1 {
			wires := fast_parse_all_integers(parts[j][1:len(parts[j]) - 1])[:]
			button_idx := j - 1
			for b in wires {
				data.lines[i].buttons[button_idx] |= (1 << u16(b))
				if b < ncols {
					data.lines[i].button_mat[button_idx][b] = 1
				}
			}
		}
	}
	return Solution{data = data, part1 = part1, part2 = part2}
}

@(private = "file")
bfs1 :: proc(config: ^MachineConfig) -> int {
	// start with zero
	states := make([dynamic]u16)
	defer delete(states)
	append(&states, 0)
	visited := make(map[u16]int)
	defer delete(visited)
	visited[0] = 1
	idx := 0
	for idx < len(states) {
		state := states[idx]
		idx += 1
		// check if we reached the target
		distance := visited[state]
		if state == config.mask {
			return distance - 1
		}
		// try all buttons
		for button in config.buttons {
			next_state := state ~ button
			if _, ok := visited[next_state]; !ok {
				visited[next_state] = distance + 1
				append(&states, next_state)
			}
		}
	}
	return -1
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day10Data)raw_data
	ret := 0
    shardfn :: proc(data: ^Day10Data, shard: int) {
        data.lines[shard].res1 = bfs1(&data.lines[shard])
    }
    run_shards(len(data.lines), data, shardfn)
	for i in 0 ..< len(data.lines) {
		ret += data.lines[i].res1
	}
	return ret
}

// Solve ILP using GLPK: minimize sum(x) subject to A^T * x = b, x >= 0, x integer
@(private = "file")
solve_ilp_glpk :: proc(config: ^MachineConfig) -> int {
	nbuttons := i32(len(config.button_mat))
	npositions := i32(len(config.button_mat[0]))

	// Create GLPK problem
	lp := glp_create_prob()
	defer glp_delete_prob(lp)

	// Set minimization
	glp_set_obj_dir(lp, GLP_MIN)

	// Add rows (constraints) - one per position
	glp_add_rows(lp, npositions)
	for p in 1 ..= npositions {
		// Equality constraint: sum = joltage[p-1]
		glp_set_row_bnds(lp, p, GLP_FX, f64(config.joltage[p - 1]), f64(config.joltage[p - 1]))
	}

	// Add columns (variables) - one per button
	glp_add_cols(lp, nbuttons)
	for b in 1 ..= nbuttons {
		// Variable >= 0, integer
		glp_set_col_bnds(lp, b, GLP_LO, 0.0, 0.0) // x >= 0
		glp_set_col_kind(lp, b, GLP_IV)           // integer
		glp_set_obj_coef(lp, b, 1.0)              // minimize sum
	}

	// Count ones in constraint matrix
	ne := i32(0)
	for b in 0 ..< nbuttons {
		for p in 0 ..< npositions {
            ne += config.button_mat[b][p] 
		}
	}

	// Build sparse matrix (1-indexed for GLPK)
	ia := make([]i32, ne + 1) // row indices
	ja := make([]i32, ne + 1) // column indices
	ar := make([]f64, ne + 1) // values
	defer delete(ia)
	defer delete(ja)
	defer delete(ar)

	k := i32(1)
	for b in 0 ..< nbuttons {
		for p in 0 ..< npositions do if config.button_mat[b][p] != 0 {
            ia[k] = p + 1              // row (1-indexed)
            ja[k] = b + 1              // column (1-indexed)
            ar[k] = f64(config.button_mat[b][p])
            k += 1
		}
	}

	// Load the constraint matrix
	glp_load_matrix(lp, ne, raw_data(ia), raw_data(ja), raw_data(ar))

	// Set up MIP solver parameters
	parm: glp_iocp
	glp_init_iocp(&parm)
	parm.msg_lev = GLP_MSG_OFF // Suppress output
	parm.presolve = 1          // Enable presolve

	// Solve the MIP
	ret := glp_intopt(lp, &parm)
	obj_val := glp_mip_obj_val(lp)
	return int(obj_val + 0.5) // Round to nearest int
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
	data := cast(^Day10Data)raw_data
	ret := 0
    shardfn :: proc(data: ^Day10Data, shard: int) {
        data.lines[shard].res2 = solve_ilp_glpk(&data.lines[shard])
    }
    run_shards(len(data.lines), data, shardfn)
	for i in 0 ..< len(data.lines) {
		ret += data.lines[i].res2
	}
	return ret
}

@(test)
test_day10 :: proc(t: ^testing.T) {
	input :=
		"[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}\n" +
		"[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}\n" +
		"[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
	defer setup_test_allocator()()
	solution := day10(input)
	testing.expect_value(t, solution.part1(solution.data), 7)
	testing.expect_value(t, solution.part2(solution.data), 33)
}

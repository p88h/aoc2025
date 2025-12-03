package main

@(private = "file")
ParsedInput :: struct {
	lines: [][]int
}

day03 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
    data.lines = make([][]int, len(lines))
    for line, idx in lines {
        data.lines[idx] = make([]int, len(line))
        for cidx in 0..<len(line) {
            data.lines[idx][cidx] = int(line[cidx] - '0')
        }
    }
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
    tot := 0
    for line in data.lines {
        pmax := 0
        max := 0
        for v in line {
            if pmax * 10 + v > max {
                max = pmax * 10 + v
            }
            if v > pmax {
                pmax = v
            }
        }
        tot += max
        // Placeholder logic for part 1
    }
	return tot
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
    tot := 0
    for line in data.lines {
        // go through all digits 12 times to figure out the biggest number of each length,
        // ending at each position
        max_num := make([]int, len(line))
        // init with single digit numbers
        for l in 0..<len(line) {
            max_num[l] = line[l]
        }
        max := 0
        for _ in 1..<12 {
            pmax := 0
            for i in 0..<len(line) {
                // pmax is the best n-1 digit number ending before position i from previous iteration
                next_num := pmax * 10 + line[i]
                // update pmax for the next position
                if max_num[i] > pmax {
                    pmax = max_num[i]
                }                
                // update max_num[i] for the next iteration
                max_num[i] = next_num
                if next_num > max {
                    max = next_num
                }
            }
        }
        tot += max
    }
    return tot
}

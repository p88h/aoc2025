package main

// Boilerplate
@(private = "file")
ParsedInput :: struct {
	nums: []int,
}

day01 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	lines := split_lines(contents)
    data.nums = make([]int, len(lines))
    for line, idx in lines {
        dir := line[0]
        amt := parse_int(line[1:])
        switch dir {
            case 'L':
                data.nums[idx] = -amt
            case 'R':
                data.nums[idx] = amt
        }
    }
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
    pos := 50
    pass := 0
    for num in data.nums {
        ofs := num 
        pos = (pos + num) % 100
        if pos == 0 {
            pass += 1
        }
    }
	return pass
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
    pos := 50
    pass := 0
    for num in data.nums {        
        pass += abs(num) / 100
        amt := num % 100
        if (pos > 0 && pos + amt <= 0) || pos + amt >= 100 {
            pass += 1
        }
        pos = (pos + 100 + amt) % 100
    }
	return pass
}

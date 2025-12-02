package main

@(private = "file")
ParsedInput :: struct {
	lines: []string
}

day00 :: proc(contents: string) -> Solution {
	data := new(ParsedInput)
	data.lines = split_lines(contents)
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
	return len(data.lines)
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
    data := cast(^ParsedInput)raw_data
	return len(data.lines)
}

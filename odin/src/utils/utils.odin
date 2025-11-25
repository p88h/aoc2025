package utils

import "core:os"
import "core:strings"
import "core:strconv"

// Read the entire contents of a file as a string
read_file :: proc(filename: string) -> (string, bool) {
    data, ok := os.read_entire_file(filename)
    if !ok {
        return "", false
    }
    return string(data), true
}

// Read file and split into lines
read_lines :: proc(filename: string) -> ([]string, bool) {
    content, ok := read_file(filename)
    if !ok {
        return nil, false
    }
    return split_lines(content), true
}

// Split string into lines, handling both \n and \r\n
split_lines :: proc(content: string) -> []string {
    lines := strings.split(content, "\n")
    // Remove empty trailing line if present
    if len(lines) > 0 && lines[len(lines)-1] == "" {
        return lines[:len(lines)-1]
    }
    return lines
}

// Parse a string to an integer, returns 0 if parsing fails
parse_int :: proc(s: string) -> int {
    trimmed := strings.trim_space(s)
    val, ok := strconv.parse_int(trimmed)
    if !ok {
        return 0
    }
    return val
}

// Parse all lines as integers
parse_int_lines :: proc(lines: []string) -> []int {
    result := make([]int, len(lines))
    for line, i in lines {
        result[i] = parse_int(line)
    }
    return result
}

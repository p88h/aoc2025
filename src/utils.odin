package main

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:path/filepath"
import "core:strconv"
import "core:strings"

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

// Split string into lines (handles \n only)
split_lines :: proc(content: string) -> []string {
	lines := strings.split(content, "\n")
	// Remove empty trailing line if present
	if len(lines) > 0 && lines[len(lines) - 1] == "" {
		return lines[:len(lines) - 1]
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

// Parse all lines as integers (caller must free the returned slice)
parse_int_lines :: proc(lines: []string) -> []int {
	result := make([]int, len(lines))
	for line, i in lines {
		result[i] = parse_int(line)
	}
	return result
}

// Download a file from a URL and save it to the specified path using curl
download_file :: proc(url: string, path: string, cookie: string = "") -> bool {
	fmt.printfln("Trying to download %s from %s", path, url)
	dir := filepath.dir(path)

	// Use curl to download the file
	args: [dynamic]string
	defer delete(args)
	append(&args, "curl")
	// append(&args, "-s") // Silent mode
	append(&args, "-f") // Fail on HTTP errors
	append(&args, "-o", path) // Output file

    if len(cookie) > 0 {
		append(&args, "-H", fmt.tprintf("Cookie: %s", cookie))
	}

	append(&args, url)

	state, out, err_out, err := os2.process_exec({command = args[:]}, context.allocator)
	if err == nil && state.exit_code == 0 {
		return true
	}

	fmt.printfln("Failed to download file (curl exit code: %d)", state.exit_code)
	fmt.printfln("Output: %s", out)
    fmt.printfln("Error: %s", err_out)
	return false
}

// Get input for a given day, downloading if necessary
get_input :: proc(day: int) -> (string, bool) {
	filename := fmt.tprintf("inputs/day%02d.txt", day)
	if !os.exists(filename) {
		cookie_data, cookie_ok := os.read_entire_file(".cookie")
		cookie := string(cookie_data) if cookie_ok else ""
		cookie = strings.trim_space(cookie)
		url := fmt.tprintf("https://adventofcode.com/2025/day/%d/input", day)
		download_file(url, filename, cookie)
	}
	return read_file(filename)
}

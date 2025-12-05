package main

import "core:testing"
@(private = "file")
Range :: struct {
    start: int,
    end: int,
    len: int,
    base: int,
}

Day2Input :: struct {
	ranges: [dynamic]Range,
}

day02 :: proc(contents: string) -> Solution {
	data := new(Day2Input)
    nums := fast_parse_all_integers(contents)
    data.ranges = make([dynamic]Range)
    // Read the ranges and make them 'nice' (split to ranges of same length)
    for idx in 0..<len(nums) / 2 {
        start := nums[idx * 2]
        end := nums[idx * 2 + 1]
        lb := 1
        ll := 0
        for lb <= start {
            lb *= 10
            ll += 1
        }
        rb := 1
        for rb <= end {
            rb *= 10
        }
        for lb < rb {
            append(&data.ranges, Range{start = start, end = lb - 1, len = ll, base = lb})            
            start = lb
            lb *= 10
            ll += 1
        }
        append(&data.ranges, Range{start = start, end = end, len = ll, base = rb})        
    }
	return Solution{data = data, part1 = part1, part2 = part2}
}

day2_sub_seq_sum :: #force_inline proc(start: int, end: int, bbase: int, mult: int) -> int {    
    pat_start := start / bbase
    pat_end := end / bbase
    if pat_start * mult < start {
        pat_start = (start + mult - 1) / mult
    }
    if pat_end * mult > end {
        pat_end = end / mult
    }
    ssum := (pat_start + pat_end) * (pat_end - pat_start + 1) / 2
    return ssum * mult
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
    data := cast(^Day2Input)raw_data
    ret := 0
    for r in data.ranges {
        if r.len % 2 != 0 {
            continue
        }
        bbase := 1
        for _ in 0..<(r.len/2) {
            bbase *= 10
        }
        ret += day2_sub_seq_sum(r.start, r.end, bbase, bbase + 1)
    }
	return ret
}

day2_make_helper_table :: proc() -> [10][5][2]int {
    help : [10][5][2]int = {}
    base := 10

    // helper table with base and multiplier for each length and period
    for len in 2..=10 {
        base *= 10
        base_shift := 1
        for rl in 1..=5 {
            base_shift *= 10
            if len <= rl || len % rl != 0 {
                continue
            }
            rep := len / rl            
            bbase := 1
            for _ in 1..<rep {
                bbase *= base_shift
            }
            mult := 0
            shift := 1
            for _ in 0..<rep {
                mult += shift
                shift *= base_shift
            }
            help[len-1][rl-1] = {bbase, mult}
        }
    }
    return help
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
    data := cast(^Day2Input)raw_data
    ret := 0
    help := day2_make_helper_table()
    
    for r in data.ranges {
        cnt := 0
        // Try all possible period lengths j that divide r.len, from largest to smallest
        for j: int = r.len/2; j >= 1; j -= 1 {
            if r.len % j != 0 {
                continue
            }
            // this can be skipped completely since it was counted at length 4
            if j == 2 && r.len == 8 {
                continue
            }
            cnt += 1
            seq_sum := day2_sub_seq_sum(r.start, r.end, help[r.len-1][j-1][0], help[r.len-1][j-1][1])
            if j == 1 && cnt > 1 {
                // since cnt > 1, this pattern was already generated (cnt - 1) times
                // So now we subtract the self-periodic patterns
                ret -= seq_sum * (cnt - 2)
            } else {
                ret += seq_sum
            }
        }
    }
	return ret
}

@(test)
test_day02 :: proc(t: ^testing.T) {
    input := "11-22,95-115,998-1012,1188511880-1188511890,222220-222224," +
"1698522-1698528,446443-446449,38593856-38593862,565653-565659," +
"824824821-824824827,2121212118-2121212124"
    defer setup_test_allocator()()
    solution := day02(input)
    testing.expect_value(t, solution.part1(solution.data), 1227775554)
    testing.expect_value(t, solution.part2(solution.data), 4174379265)
}   
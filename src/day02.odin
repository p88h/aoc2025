package main

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
	return Solution{data = data, part1 = part1, part2 = part2, cleanup = cleanup_raw_data}
}

@(private = "file")
part1 :: proc(raw_data: rawptr) -> int {
    data := cast(^Day2Input)raw_data
    ret := 0
    for r in data.ranges {
        if r.len % 2 != 0 {
            continue
        }
        b := 1
        for _ in 0..<(r.len/2) {
            b *= 10
        }
        for i := r.start / b; i * b + i <= r.end; i += 1 {
            if i * b + i < r.start {
                continue
            }
            ret += i * b + i
        }
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

day2_make_periodic_table :: proc() -> [100000]bool {
    // helper table to exlude self-periodic patterns
    // This could probably be optimized by checking the length only, but then it needs
    // to consider ranges at different periods don't overlap cleanly, and computing the table is quick enough.
    // (the cost is basically 0-allocating the table)
    table := [100000]bool{}
    for d in 1..=9 {
        n := d
        for r in 2..=5 {
            n = n * 10 + d
            table[n] = true
        }
    }
    for d in 10..=99 {
        table[d * 100 + d] = true        
    }
    return table
}

@(private = "file")
part2 :: proc(raw_data: rawptr) -> int {
    data := cast(^Day2Input)raw_data
    ret := 0
    help := day2_make_helper_table()
    periodic := day2_make_periodic_table()
    
    for r in data.ranges {
        // Try all possible period lengths j that divide r.len, from largest to smallest
        for j: int = r.len/2; j >= 1; j -= 1 {
            if r.len % j != 0 {
                continue
            }
            rep := r.len / j
            bbase := help[r.len-1][j-1][0]
            mult := help[r.len-1][j-1][1]
            pat_start := r.start / bbase
            pat_end := r.end / bbase
            
            for p := pat_start; p * mult <= r.end; p += 1 {
                val := p * mult
                if val < r.start {
                    continue
                }
                // Check if this pattern has a smaller primitive period by checking if p itself is periodic.
                if periodic[p] {
                    continue
                }
                ret += val
            }
        }
    }
	return ret
}

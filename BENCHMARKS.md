CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 47.6 µs 11.1 µs 14.3 µs 73.1 µs (+-1%) iter=36010    
day 02: 1.8 µs  0.1 µs  0.4 µs  2.4 µs (+-6%)  iter=98110    
day 03: 65.2 µs 2.7 µs  16.3 µs 84.2 µs (+-1%) iter=64110     
day 04: 85.1 µs 6.1 µs  0.1 ms  0.2 ms (+-1%)  iter=1010    
day 05: 56.0 µs 5.4 µs  0.1 µs  61.6 µs (+-1%) iter=24110    
day 06: 17.3 µs 8.0 µs  8.5 µs  33.9 µs (+-1%) iter=44110    
day 07: 46.0 ns 3.4 µs  35.0 ns 3.5 µs (+-4%)  iter=98110    
day 08: 0.3 ms  10.4 µs 41.9 µs 0.4 ms (+-1%)  iter=2510     

Total time:     0.9 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-11:e5153a937` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01:	34.6 µs	13.1 µs	11.8 µs	59.6 µs (+-5%) iter=90010
day 02:	1.7 µs	95.0 ns	0.3 µs	2.2 µs (+-1%)  iter=29110
day 03:	30.9 µs	3.7 µs	6.1 µs	40.8 µs (+-4%) iter=98110
day 04:	38.3 µs	5.7 µs	87.9 µs	0.1 ms (+-0%)  iter=1010
day 05:	43.1 µs	7.2 µs 	83.0 ns	50.4 µs (+-0%) iter=9110
day 06:	17.4 µs	8.7 µs	8.1 µs	34.2 µs (+-0%) iter=9110
day 07:	18.0 ns	4.9 µs	16.0 ns	5.0 µs (+-1%)  iter=9110
day 08:	0.1 ms	8.3 µs 	39.6 µs	0.2 ms (+-1%)  iter=1510

Total time: 	0.5 ms
```

CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 95.8 µs 10.9 µs 13.5 µs 0.1 ms (+-1%) iter=1510
day 02: 1.8 µs  0.1 µs  0.4 µs  2.4 µs (+-4%) iter=98110
day 03: 81.4 µs 13.9 µs 0.1 ms  0.2 ms (+-1%) iter=9510    

Total time:     0.3 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-11:e5153a937` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01:	74.3 µs	13.9 µs	12.2 µs	0.1 ms (+-2%) iter=64810
day 02:	2.0 µs	89.0 ns	0.3 µs	2.4 µs (+-1%) iter=19110
day 03:	20.9 µs	9.3 µss	59.2 µs	89.5 µs (+-1%) iter=9110

Total time: 	0.1 ms
```

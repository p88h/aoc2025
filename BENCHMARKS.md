CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 49.6 µs 10.8 µs 14.3 µs 74.8 µs (+-1%) iter=19110
day 02:  1.8 µs  0.1 µs  0.4 µs  2.4 µs (+-7%) iter=981100
day 03: 65.3 µs  2.7 µs 14.8 µs 82.9 µs (+-1%) iter=641100
day 04: 94.0 µs  6.0 µs  0.1 ms  0.2 ms (+-1%) iter=1510
day 05: 55.2 µs  4.2 µs  0.1 µs 59.5 µs (+-1%) iter=29110
day 06: 17.3 µs  8.1 µs  6.7 µs 32.2 µs (+-1%) iter=741100
day 07: 37.0 ns  3.3 µs 30.0 ns  3.4 µs (+-2%) iter=981100
day 08:  0.3 ms 11.0 µs 45.9 µs  0.4 ms (+-1%) iter=15100
day 09: 11.4 µs  2.8 µs  0.2 µs 14.5 µs (+-0%) iter=9110

Total time:   0.8 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-12:6ef91e265` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01: 35.6 µs 13.8 µs 12.1 µs 61.6 µs (+-1%) iter=56010
day 02:  1.6 µs 95.0 ns  0.3 µs  2.0 µs (+-5%) iter=98110
day 03: 32.2 µs  5.5 µs  6.2 µs 44.0 µs (+-1%) iter=89110
day 04: 42.1 µs  5.9 µs 87.3 µs  0.1 ms (+-2%) iter=99100
day 05: 44.2 µs  8.4 µs 85.0 ns 52.8 µs (+-1%) iter=9110
day 06: 18.2 µs  8.8 µs  7.5 µs 34.6 µs (+-1%) iter=9110
day 07: 26.0 ns  5.0 µs 17.0 ns  5.0 µs (+-1%) iter=34110
day 08:  0.2 ms  9.0 µs 40.6 µs  0.2 ms (+-0%) iter=1010

Total time:   0.5 ms
```

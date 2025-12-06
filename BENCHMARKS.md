CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 52.0 µs 10.9 µs 13.9 µs 76.9 µs (+-1%) iter=31010    
day 02: 1.9 µs  0.1 µs  0.4 µs  2.4 µs  (+-7%) iter=98110     
day 03: 65.0 µs 2.7 µs  15.3 µs 83.1 µs (+-1%) iter=69110     
day 04: 85.0 µs 6.1 µs  0.1 ms  0.2 ms  (+-2%) iter=9910    
day 05: 56.4 µs 4.8 µs  0.1 µs  61.3 µs (+-1%) iter=24110    

Total time:     0.4 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-11:e5153a937` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01: 32.6 µs 13.3 µs 12.7 µs 58.8 µs (+-2%) iter=90010
day 02: 1.5 µs  0.1 µs  0.3 µs  1.9 µs  (+-3%) iter=98110
day 03: 29.9 µs 3.6 µs  6.2 µs  39.8 µs (+-1%) iter=14110
day 04: 40.4 µs 5.7 µs  84.7 µs 0.1 ms  (+-5%) iter=9910
day 05: 41.8 µs 7.4 µs  0.1 µs  49.4 µs (+-1%) iter=24110
day 06: 18.6 µs 8.9 µs  8.4 µs  36.0 µs (+-1%) iter=9110

Total time:     0.3 ms
```

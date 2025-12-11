CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 47.9 µs 11.0 µs 13.7 µs 72.7 µs (+-1%) iter=36010  
day 02:  1.8 µs  0.1 µs  0.4 µs  2.4 µs (+-5%) iter=98110   
day 03: 64.9 µs  3.2 µs 14.1 µs 82.2 µs (+-1%) iter=14110   
day 04: 87.4 µs  5.8 µs  0.1 ms  0.2 ms (+-1%) iter=2010  
day 05: 54.2 µs  4.7 µs  0.1 µs 59.1 µs (+-1%) iter=14110  
day 06: 17.4 µs 11.2 µs  8.1 µs 36.8 µs (+-1%) iter=19110  
day 07: 40.0 ns  3.7 µs 44.0 ns  3.8 µs (+-3%) iter=98110  
day 08:  0.3 ms 11.0 µs 44.6 µs  0.4 ms (+-1%) iter=3510   
day 09: 11.3 µs  3.0 µs  0.1 µs 14.5 µs (+-1%) iter=34110  
day 10:  0.1 ms 94.8 µs  0.5 ms  0.7 ms (+-1%) iter=2610  
day 11: 80.9 µs 10.1 µs  4.9 µs 96.0 µs (+-1%) iter=19110  

Total time:   1.7 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-12:6ef91e265` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01: 34.5 µs 13.0 µs 12.1 µs 59.8 µs (+-2%) iter=90010
day 02:  1.4 µs 94.0 ns  0.2 µs  1.8 µs (+-2%) iter=98110
day 03: 30.2 µs  4.8 µs  5.8 µs 40.9 µs (+-0%) iter=9110
day 04: 47.6 µs  5.5 µs 83.4 µs  0.1 ms (+-0%) iter=1010
day 05: 41.5 µs  8.3 µs 69.0 ns 50.0 µs (+-1%) iter=9110
day 06: 17.7 µs  8.6 µs  7.9 µs 34.3 µs (+-0%) iter=9110
day 07: 20.0 ns  4.7 µs 16.0 ns  4.7 µs (+-1%) iter=14110
day 08:  0.2 ms 11.6 µs 41.9 µs  0.2 ms (+-1%) iter=1010
day 09: 12.2 µs  1.9 µs  0.1 µs 14.3 µs (+-1%) iter=19110
day 10: 89.3 µs 39.5 µs  0.5 ms  0.7 ms (+-1%) iter=2110
day 11: 40.9 µs  4.4 µs  4.3 µs 49.7 µs (+-4%) iter=98110

Total time:   1.3 ms
```

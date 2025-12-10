CPU: Intel Core I7-13700K (8+8-core / 24-thread)

OS: Win11 + WSL2 / Ubuntu 24.04

Odin: `dev-2025-11-nightly`, build flags: `-o:speed`

```
        parse   part1   part2   total
day 01: 52.9 µs 10.9 µs 13.4 µs 77.4 µs (+-1%) iter=9110  
day 02:  1.6 µs  0.1 µs  0.4 µs  2.2 µs (+-3%) iter=98110   
day 03: 65.3 µs  2.8 µs 15.1 µs 83.3 µs (+-2%) iter=98110  
day 04: 92.9 µs  5.8 µs  0.1 ms  0.2 ms (+-1%) iter=9010  
day 05: 56.8 µs  4.1 µs  0.1 µs 61.2 µs (+-1%) iter=14110  
day 06: 18.4 µs  8.1 µs  6.4 µs 32.9 µs (+-1%) iter=19110  
day 07: 39.0 ns  3.3 µs 31.0 ns  3.4 µs (+-3%) iter=98110   
day 08:  0.3 ms 10.6 µs 45.0 µs  0.4 ms (+-1%) iter=2010   
day 10:  0.1 ms  0.2 ms  0.6 ms  1.0 ms (+-1%) iter=1440  

Total time:   1.9 ms
```

CPU: Apple M3 Max (12+4 cores)

OS: Tahoe 26.1

Odin: `dev-2025-12:6ef91e265` (Homebrew), build flags: `-o:speed`


```
        parse   part1   part2   total
day 01: 38.8 µs 15.3 µs 13.5 µs 67.7 µs (+-1%) iter=46010   
day 02:  1.5 µs  0.1 µs  0.3 µs  2.0 µs (+-6%) iter=98110   
day 03: 33.4 µs  5.7 µs  6.3 µs 45.5 µs (+-1%) iter=9110  
day 04: 42.3 µs  6.7 µs 98.1 µs  0.1 ms (+-4%) iter=9910  
day 05: 47.1 µs 10.5 µs  0.2 µs 57.9 µs (+-1%) iter=29110  
day 06: 19.8 µs  9.7 µs  8.4 µs 38.0 µs (+-1%) iter=34110  
day 07: 19.0 ns  5.3 µs 38.0 ns  5.3 µs (+-4%) iter=98110  
day 08:  0.2 ms 12.0 µs 46.5 µs  0.2 ms (+-1%) iter=1510  
day 09: 13.1 µs  2.0 µs  0.1 µs 15.4 µs (+-1%) iter=9110  

Total time:   0.6 ms
```

# aoc2025
Advent of Code 2025

## Odin Solutions

This repository contains solutions for Advent of Code 2025 implemented in [Odin](https://odin-lang.org/).

### Prerequisites

- [Odin compiler](https://odin-lang.org/docs/install/) installed and available in PATH

### Building

```bash
make build
```

Or with the Odin compiler path specified:

```bash
ODIN=/path/to/odin make build
```

### Running

Run a specific day's solution:

```bash
./out/aoc2025 1                    # Run day 1 with default input
./out/aoc2025 day01                # Same as above
./out/aoc2025 1 custom_input.txt   # Run day 1 with custom input file
```

Or use make:

```bash
make run DAY=1
```

### Project Structure

```
├── Makefile           # Build configuration
├── inputs/            # Input files (dayNN.txt)
├── src/
│   ├── main.odin      # Main entry point
│   ├── dayNN.odin     # Solutions for each day (one file per day)
│   └── utils/         # Common utility functions
│       └── utils.odin # File reading, parsing helpers
└── out/               # Build output (gitignored)
```

### Adding a New Day

1. Create a new solution file: `src/dayNN.odin`
2. Add `dayNN_run`, `dayNN_part1`, and `dayNN_part2` procedures
3. Add the day to the switch statement in `main.odin`

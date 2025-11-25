# aoc2025
Advent of Code 2025

## Odin Solutions

This repository contains solutions for Advent of Code 2025 implemented in [Odin](https://odin-lang.org/).

### Prerequisites

- [Odin compiler](https://odin-lang.org/docs/install/) installed and available in PATH

### Building

```bash
cd odin
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
odin/
├── Makefile           # Build configuration
├── inputs/            # Input files (dayNN.txt)
├── src/
│   ├── main.odin      # Main entry point
│   ├── utils/         # Common utility functions
│   │   └── utils.odin # File reading, parsing helpers
│   └── dayNN/         # Solutions for each day
│       └── dayNN.odin
└── out/               # Build output (gitignored)
```

### Adding a New Day

1. Create a new directory: `src/dayNN/`
2. Create the solution file: `src/dayNN/dayNN.odin`
3. Import the day in `src/main.odin`
4. Add the day to the switch statement in `main.odin`

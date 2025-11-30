p88h x Advent of Code 2025 (Hello, Odin)
========================================

This is a repository containing solutions for the 2025 Advent of Code (https://adventofcode.com/).

This years language of choice is [Odin](https://odin-lang.org/).

After installing Odin, you should be able to run the solutions code by using

```
# run all days
$ odin run src
# run one specific day 
$ odin run src -- 4
```

There are also some Makefile targets, you can use `make help` to list what that does. 

Benchmarking
============

Automatic, the runner always benchmarks the results.

Reference benchmark results are added here as well (BENCHMARKS.md)

Visualisations
==============

`vis` directory contains visualisations for all days implemented with Raylib. To get this to run you can try:

```
$ odin run vis
# run & record select a specific day 
$ odin run vis -- rec 23
```

You can use day selection as with regular runner. Using `rec`, the visualisation will be recorded to file `out.mp4`. 
This requires `ffmpeg` to be installed locally.

If you don't care about tinkering with build system enough, visualisations are also published to [YouTube](https://www.youtube.com/@p88h.)

You can also hop on straight to the [2025 playlist](https://youtu.be/dQw4w9WgXcQ)

Copyright disclaimer
====================

Licensed under the Apache License, Version 2.0 (the "License");
you may not use these files except in compliance with the License.
You may obtain a copy of the License at

   https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

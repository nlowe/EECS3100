# EECS 3100 - Microsystems Design [![Build Status](https://travis-ci.org/nlowe/EECS3100.svg?branch=master)](https://travis-ci.org/nlowe/EECS3100)

Projects and code samples for EECS 3100 - Microsystems Design for the Fall 2017 Semester
at the University of Toledo

## Building

Each project comes with a `Makefile`. To assemble, link, and create a flashable image for each project,
simply invoke `make` in the project's directory. Invoking `make clean` should clean things up.

The `shared` folder contains parts shared across all projects such as startup boiler plate and the linker
script for the device we use in the lab. To link for a different device, alter `shared/device.ld`.

You can also build and clean all projects by invoking `make` at the root of this repo.

## License

All projects and code is licensed under the MIT License unless otherwise specified

Copyright 2017 Nathan Lowe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
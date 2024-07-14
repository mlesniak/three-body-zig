# Overview

This is a playground project to demonstrate the effects of gravity using
Newton's laws of motion. The project is written in [Zig](https://ziglang.org/)
and uses [Raylib](https://raylib.com) for visualization.

It serves as a learning project for me to get more familiar with Zig and Raylib,
and is very far away from being a complete, polished or somehow tested project.

# Demo

![Demo](https://github.com/mlesniak/three-body-zig/blob/main/demo.mp4)

# Foundation

The equation for universal gravitation takes the form:

![Gravitational force equation](https://github.com/mlesniak/three-body-zig/blob/main/formula.svg)

where F is the gravitational force acting between two objects, m1 and m2 are the masses of the objects, 
r is the distance between the centers of their masses, and G is the gravitational constant.

# Building

A simple

```
zig build run
```

should be sufficient to build and run the project. On the first run it will
also try to compile Raylib and might complain about missing dependencies. 
Install them as needed.
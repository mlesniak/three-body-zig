const std = @import("std");
const core = @import("core/core.zig");
const simulation = @import("core/simulation.zig");

pub fn main() !void {
    const o1 = core.Object{ .pos = .{ .x = 0, .y = 0 }, .vel = .{ .x = 0, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    const o2 = core.Object{ .pos = .{ .x = 1, .y = 0 }, .vel = .{ .x = 0, .y = 1 }, .acc = core.Vec2.zero(), .mass = 1 };
    const o3 = core.Object{ .pos = .{ .x = 0, .y = 1 }, .vel = .{ .x = -1, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    var objects = [_]core.Object{ o1, o2, o3 };

    var sim = simulation.Simulation.init(&objects);
    sim.step(1.0);
    sim.step(1.0);
    sim.step(1.0);

    // @mlesniak Introduce raylib.
}


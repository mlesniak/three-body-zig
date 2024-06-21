// const std = @import("std");
// const core = @import("core/core.zig");
// const simulation = @import("core/simulation.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    // const o1 = core.Object{ .pos = .{ .x = 0, .y = 0 }, .vel = .{ .x = 0, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    // const o2 = core.Object{ .pos = .{ .x = 1, .y = 0 }, .vel = .{ .x = 0, .y = 1 }, .acc = core.Vec2.zero(), .mass = 1 };
    // const o3 = core.Object{ .pos = .{ .x = 0, .y = 1 }, .vel = .{ .x = -1, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    // var objects = [_]core.Object{ o1, o2, o3 };
    //
    // var sim = simulation.Simulation.init(&objects);
    // sim.step(1.0);
    // sim.step(1.0);
    // sim.step(1.0);

    const width = 800;
    const height = 600;

    ray.InitWindow(width, height, "raylib [core] example - basic window");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();

        ray.DrawCircle(100, 100, 10, ray.YELLOW);

        defer ray.EndDrawing();
    }
}


const std = @import("std");
const core = @import("core/core.zig");
const simulation = @import("core/simulation.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

fn initSimulation(alloc: *const std.mem.Allocator) !simulation.Simulation {
    const o0 = core.Object{
        .pos = .{ .x = 7_000_000_000, .y = 1_000_000_000 },
        .vel = .{ .x = 0, .y = 0 },
        .acc = core.Vec2.zero(),
        .mass = 1e1,
    };
    const o1 = core.Object{
        .pos = .{ .x = 5_000_000_000, .y = 3_000_000_000 },
        .vel = .{ .x = 0, .y = 0 },
        .acc = core.Vec2.zero(),
        .mass = 1e40,
    };
    // const o3 = core.Object{ .pos = .{ .x = 2_500_000_000, .y = 5_000_000_000 }, .vel = .{ .x = 0, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1e10 };
    var objects = try alloc.alloc(core.Object, 2);
    objects[0] = o0;
    objects[1] = o1;
    // objects[2] = o3;
    const sim = simulation.Simulation.init(objects);
    return sim;
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const sim = try initSimulation(&alloc);

    const width = 1000;
    const height = 1000;

    ray.InitWindow(width, height, "Three body problem - simulation");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    const dt: f64 = 0.001;

    const zoomFactor: f64 = 10_000_000;
    var advance: bool = false;

    var i: i32 = 0;
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.BLACK);

        for (sim.objects) |o| {
            // std.debug.print("x positions\n", .{});
            // std.debug.print("{}\n", .{o.pos.x});
            // const f = o.pos.x / zoomFactor;
            const x: i32 = @intFromFloat(o.pos.x / zoomFactor);
            const y: i32 = @intFromFloat(o.pos.y / zoomFactor);
            // if (i == 0) {
            //     std.debug.print("{}, {}, {}, {}\n", .{o.pos.x, x, y, f});
            // }
            ray.DrawCircle(x, y, 10, ray.RED);
        }

        if (ray.IsKeyDown(ray.KEY_J)) {
            advance = true;
        }

        if (advance) {
            advance = false;
            sim.step(dt);
            for (sim.objects, 0..sim.objects.len) |o, idx| {
                std.debug.print("[{}] {}\n", .{idx, o});
            }
            std.debug.print("\n", .{});
        }

        i += 1;
    }
}

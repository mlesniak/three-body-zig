const std = @import("std");
const core = @import("core/core.zig");
const simulation = @import("core/simulation.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

// @mlesniak explain units, m/s, kg, ...
fn initSimulation(alloc: *const std.mem.Allocator) !simulation.Simulation {
    // const o0 = core.Object{
    //     .pos = core.Vec2{ .x = 5_000_000_000, .y = 4_000_000_000 },
    //     .vel = core.Vec2{ .x = -1e4, .y = -1e4 },
    //     .acc = core.Vec2{ .x = 0, .y = 0 },
    //     .mass = 1e23,
    // };
    // const o1 = core.Object{
    //     .pos = core.Vec2{ .x = 5_000_000_000, .y = 5_000_000_000 },
    //     .vel = core.Vec2{ .x = 0, .y = -1e4 },
    //     .acc = core.Vec2{ .x = 0, .y = 0 },
    //     .mass = 1e24,
    // };
    // const o2 = core.Object{
    //     .pos = core.Vec2{ .x = 4_000_000_000, .y = 6_500_000_000 },
    //     .vel = core.Vec2{ .x = 3e5, .y = 1e4 },
    //     .acc = core.Vec2{ .x = 0, .y = 0 },
    //     .mass = 1e22,
    // };
    const o0 = core.Object{
        .pos = .{ .x = 5_000_000_000, .y = 5_000_000_000 },
        .vel = .{ .x = 0, .y = 0 },
        .acc = core.Vec2.zero(),
        .mass = 1e28,
        .color = ray.RED,
    };

    const o1 = core.Object{
        .pos = .{ .x = 4_000_000_000, .y = 4_000_000_000 },
        .vel = .{ .x = 0, .y = 1.2e4 },
        .acc = core.Vec2.zero(),
        .mass = 1e26,
        .color = ray.GREEN,
    };

    const o2 = core.Object{
        .pos = .{ .x = 6_000_000_000, .y = 4_000_000_000 },
        .vel = .{ .x = 0, .y = -1.2e4 },
        .acc = core.Vec2.zero(),
        .mass = 1e23,
        .color = ray.BLUE,
    };
    const o3 = core.Object{
        .pos = .{ .x = 5_000_000_000, .y = 6_000_000_000 },
        .vel = .{ .x = 8e4, .y = 0 },
        .acc = core.Vec2.zero(),
        .mass = 1e24,
        .color = ray.YELLOW
    };

    var objects = try alloc.alloc(core.Object, 4);
    objects[0] = o0;
    objects[1] = o1;
    objects[2] = o2;
    objects[3] = o3;
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

    const dt: f64 = 250;

    const zoomFactor: f64 = 10_000_000;
    var advance: bool = true;

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
            for (o.trail) |tp| {
                const tx: i32 = @intFromFloat(tp.x / zoomFactor);
                const ty: i32 = @intFromFloat(tp.y / zoomFactor);
                ray.DrawCircle(tx, ty, 1, o.color);
            }
            ray.DrawCircle(x, y, 10, o.color);
        }

        if (ray.IsKeyDown(ray.KEY_J)) {
            advance = true;
        }

        if (advance) {
            // advance = false;
            sim.step(dt);
            // for (sim.objects, 0..sim.objects.len) |o, idx| {
            //     std.debug.print("[{}] {}\n", .{ idx, o });
            // }
            // std.debug.print("\n", .{});
        }

        i += 1;
    }
}

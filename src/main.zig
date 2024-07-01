const std = @import("std");
const core = @import("core/core.zig");
const simulation = @import("core/simulation.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

// @mlesniak explain units, m/s, kg, ...
fn initSimulation(alloc: *const std.mem.Allocator) !simulation.Simulation {
    const o0 = core.Object{
        .pos = .{ .x = 3_000_000_000, .y = 5_000_000_000 },
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
        .vel = .{ .x = 8e3, .y = 1e3 },
        .acc = core.Vec2.zero(),
        .mass = 1e24,
        .color = ray.YELLOW,
    };
    const o4 = core.Object{
        .pos = .{ .x = 7_000_000_000, .y = 2_000_000_000 },
        .vel = .{ .x = -5e3, .y = 0 },
        .acc = core.Vec2.zero(),
        .mass = 1e18,
        .color = ray.PURPLE,
    };

    var objects = try alloc.alloc(core.Object, 5);
    objects[0] = o0;
    objects[1] = o1;
    objects[2] = o2;
    objects[3] = o3;
    objects[4] = o4;
    const sim = simulation.Simulation.init(objects);
    return sim;
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const sim = try initSimulation(&alloc);

    const width = 1000;
    const height = 1000;

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT);
    ray.InitWindow(width, height, "Gravity simulation");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    const dt: f64 = 250;
    const stepsPerFrame: i32 = 10;

    var rnd = std.rand.DefaultPrng.init(1234);
    const zoomFactor: f64 = 10_000_000;

    var i: i32 = 0;
    const bg = ray.Color{ .r = 15, .g = 15, .b = 15, .a = 255 };
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(bg);

        for (sim.objects) |o| {
            for (o.trail) |tp| {
                const tx: i32 = @intFromFloat(tp.x / zoomFactor);
                const ty: i32 = @intFromFloat(tp.y / zoomFactor);
                ray.DrawCircle(tx, ty, 1, o.color);
            }
        }

        for (sim.objects) |o| {
            const x: i32 = @intFromFloat(o.pos.x / zoomFactor);
            const y: i32 = @intFromFloat(o.pos.y / zoomFactor);
            ray.DrawCircle(x, y, 10, o.color);
            // Very simple antialiasing.
            ray.DrawCircle(x + randInt(&rnd, -3, 3), y + randInt(&rnd, -3, 3), 10, ray.Fade(o.color, 0.3));
        }

        {
            var s: i32 = 0;
            while (s < stepsPerFrame) : (s += 1) {
                sim.step(dt);
            }
        }

        i += 1;
    }
}

fn randInt(r: *std.rand.Random.Xoshiro256, min: i32, max: i32) i32 {
    const f1: f32 = @floatFromInt(min);
    const f2: f32 = @floatFromInt(max);
    return @intFromFloat(f1 + std.rand.float(r.random(), f32) * (f2 - f1));
}

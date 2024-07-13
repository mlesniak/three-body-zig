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
        .vel = .{ .x = -7e3, .y = 5e2 },
        .acc = core.Vec2.zero(),
        .mass = 1e19,
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
    var zoomFactor: f64 = 10_000_000;

    // Shift values.
    var dx: f64 = 0;
    var dy: f64 = 0;
    var startX: i32 = -1;
    var startY: i32 = -1;

    var i: i32 = 0;
    const bg = ray.Color{ .r = 20, .g = 20, .b = 20, .a = 255 };
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        const zoom = ray.GetMouseWheelMove();
        if (zoom != 0) {
            // @mlesniak adjust for location
            zoomFactor += zoom * -1_000_000;
            dx += zoom * 1_000_000;
            dy += zoom * 1_000_000;
            std.debug.print("mouse wheel {}\n", .{zoomFactor});
        }

        if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
            if (startX == -1) {
                startX = ray.GetMouseX();
                startY = ray.GetMouseY();
            }
            const curX = ray.GetMouseX();
            const curY = ray.GetMouseY();
            const dxt: f64 = @floatFromInt(curX - startX);
            const dyt: f64 = @floatFromInt(curY - startY);
            dx += dxt * -zoomFactor;
            dy += dyt * -zoomFactor;
            std.debug.print("{}/{}\n", .{ dxt, dyt });
            startX = curX;
            startY = curY;
        }
        if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)) {
            std.debug.print("Released\n", .{});
            startX = -1;
            startY = -1;
        }

        ray.ClearBackground(bg);

        for (sim.objects) |o| {
            for (o.trail, 0..) |tp, ix| {
                const tx: i32 = @intFromFloat((tp.x - dx) / zoomFactor);
                const ty: i32 = @intFromFloat((tp.y - dy) / zoomFactor);
                const fx: f32 = @floatFromInt(ix);
                const gx: f32 = @floatFromInt(o.trail.len);
                ray.DrawCircle(tx, ty, 1, ray.Fade(o.color, fx / gx * 0.8));
            }
        }

        for (sim.objects) |o| {
            const x: i32 = @intFromFloat((o.pos.x - dx) / zoomFactor);
            const y: i32 = @intFromFloat((o.pos.y - dy) / zoomFactor);
            ray.DrawCircle(x, y, 5, o.color);
            // Basic beautification.
            ray.DrawCircle(x + randInt(&rnd, -2, 2), y + randInt(&rnd, -2, 2), 10, ray.Fade(o.color, 0.2));
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

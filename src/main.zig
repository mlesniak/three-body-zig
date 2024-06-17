const std = @import("std");
const core = @import("core/core.zig");

pub fn main() !void {
    const delta = 1;

    const o1 = core.Object{ .pos = .{ .x = 0, .y = 0 }, .vel = .{ .x = 0, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    const o2 = core.Object{ .pos = .{ .x = 1, .y = 0 }, .vel = .{ .x = 0, .y = 1 }, .acc = core.Vec2.zero(), .mass = 1 };
    const o3 = core.Object{ .pos = .{ .x = 0, .y = 1 }, .vel = .{ .x = -1, .y = 0 }, .acc = core.Vec2.zero(), .mass = 1 };
    var objects: [3]core.Object = [_]core.Object{ o1, o2, o3 };

    var step: i64 = 0;
    while (step < 3) : (step += 1) {
        var accs: [3]core.Vec2 = undefined;
        std.debug.print("\nStep {} with delta={}\n", .{ step, delta });
        // Compute new acceleration.
        for (0..objects.len) |i| {
            accs[i] = computeAccSum(objects, i);
        }
        for (0..accs.len) |i| {
            const acc = accs[i];
            std.debug.print("accs[{}] = ({}, {})\n", .{ i, acc.x, acc.y });
        }

        // Update velocity and position.
        for (0..objects.len) |i| {
            var o = &objects[i];
            const acc = accs[i];
            const newVel = o.vel.add(acc.scale(delta));
            const newPos = o.pos.add(newVel.scale(delta));
            o.pos = newPos;
            o.vel = newVel;
            std.debug.print("objects[{}] = ({}, {}, {})\n", .{ i, newPos.x, newPos.y, newVel.len() });
        }
    }
}

fn computeAccSum(objects: [3]core.Object, current: u64) core.Vec2 {
    const curObject = objects[current];
    var accSum = core.Vec2.zero();
    for (objects, 0..) |o, i| {
        if (i != current) {
            const acc = computeGravitationalForce(curObject, o);
            accSum.x += acc.x;
            accSum.y += acc.y;
        }
    }
    return accSum;
}

// @mlesniak move this to object struct.
fn computeGravitationalForce(o1: core.Object, o2: core.Object) core.Vec2 {
    const g = 6.67430E-11;
    const r = o2.pos.sub(o1.pos);
    const ru = r.unit();
    const rd = r.len();
    const f = g * (o1.mass * o2.mass) / (rd * rd);
    return ru.scale(f);
}

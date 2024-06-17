const std = @import("std");

// @mlesniak move to different packages and/or files and use import.
const Vec2 = struct {
    x: f64 = 0,
    y: f64 = 0,

    pub fn zero() Vec2 {
        return Vec2{};
    }

    pub fn scale(self: Vec2, f: f64) Vec2 {
        return Vec2{ .x = self.x * f, .y = self.y * f };
    }

    pub fn sub(self: Vec2, o: Vec2) Vec2 {
        return Vec2{ .x = self.x - o.x, .y = self.y - o.y };
    }

    pub fn add(self: Vec2, o: Vec2) Vec2 {
        return Vec2{ .x = self.x + o.x, .y = self.y + o.y };
    }

    pub fn len(self: Vec2) f64 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn unit(self: Vec2) Vec2 {
        return self.scale(1.0 / self.len());
    }
};

const Object = struct {
    pos: Vec2,
    vel: Vec2,
    acc: Vec2,
    mass: f64, // in kg
};

const F = struct {
    n: i32
};

pub fn main() !void {
    const delta = 1;

    const o1 = Object{ .pos = .{ .x = 0, .y = 0 }, .vel = .{ .x = 0, .y = 0 }, .acc = Vec2.zero(), .mass = 1 };
    const o2 = Object{ .pos = .{ .x = 1, .y = 0 }, .vel = .{ .x = 0, .y = 1 }, .acc = Vec2.zero(), .mass = 1 };
    const o3 = Object{ .pos = .{ .x = 0, .y = 1 }, .vel = .{ .x = -1, .y = 0 }, .acc = Vec2.zero(), .mass = 1 };
    var objects: [3]Object = [_]Object{ o1, o2, o3 };

    var step: i64 = 0;
    while (step < 3) : (step += 1) {
        var accs: [3]Vec2 = undefined;
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

fn computeAccSum(objects: [3]Object, current: u64) Vec2 {
    const curObject = objects[current];
    var accSum = Vec2.zero();
    for (objects, 0..) |o, i| {
        if (i != current) {
            const acc = computeGravitationalForce(curObject, o);
            accSum.x += acc.x;
            accSum.y += acc.y;
        }
    }
    return accSum;
}

fn computeGravitationalForce(o1: Object, o2: Object) Vec2 {
    const g = 6.67430E-11;
    const r = o2.pos.sub(o1.pos);
    const ru = r.unit();
    const rd = r.len();
    const f = g * (o1.mass * o2.mass) / (rd * rd);
    return ru.scale(f);
}

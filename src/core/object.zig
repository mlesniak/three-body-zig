const std = @import("std");
const Vec2 = @import("vec.zig").Vec2;
const ray = @cImport({
    @cInclude("raylib.h");
});

const trailLength = 512;

pub const Object = struct {
    pos: Vec2,
    vel: Vec2,
    acc: Vec2,
    mass: f64, // in kg
    trail: [trailLength]Vec2 = std.mem.zeroes([trailLength]Vec2),
    trailIndex: u32 = 0,
    tick: u32 = 0,
    color: ray.Color,

    pub fn computeGravitationalForce(self: Object, o2: Object) Vec2 {
        const g = 6.67430E-11;
        const r = o2.pos.sub(self.pos);
        const rd = r.len();
        if (rd == 0) {
            return Vec2.zero();
        }

        const ru = r.unit();
        const f = g * (self.mass * o2.mass) / (rd * rd);
        return ru.scale(f);
    }
};

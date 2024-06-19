const Vec2 = @import("vec.zig").Vec2;

pub const Object = struct {
    pos: Vec2,
    vel: Vec2,
    acc: Vec2,
    mass: f64, // in kg

    // @mlesniak move this to object struct.
    pub fn computeGravitationalForce(self: Object, o2: Object) Vec2 {
        const g = 6.67430E-11;
        const r = o2.pos.sub(self.pos);
        const ru = r.unit();
        const rd = r.len();
        const f = g * (self.mass * o2.mass) / (rd * rd);
        return ru.scale(f);
    }
};

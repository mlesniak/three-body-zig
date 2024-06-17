const Vec2 = @import("vec.zig").Vec2;

pub const Object = struct {
    pos: Vec2,
    vel: Vec2,
    acc: Vec2,
    mass: f64, // in kg
};

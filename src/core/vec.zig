const std = @import("std");

pub const Vec2 = struct {
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
    const length = self.len();
    if (length == 0) {
      return Vec2{ .x = 0, .y = 0 };
    }
    return Vec2{
      .x = self.x / length,
      .y = self.y / length,
    };
  }
};


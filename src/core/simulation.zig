const Object = @import("object.zig");

pub const Simulation = struct {
  step: i32,
  objects: []const Object,

  pub fn init(objects: []const Object) Simulation {
    return Simulation{
      .step = 1,
      .objects = objects,
    };
  }
};
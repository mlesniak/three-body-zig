const Object = @import("core.zig").Object;
const Vec2 = @import("core.zig").Vec2;
const std = @import("std");

pub const Simulation = struct {
    objects: []Object,

    pub fn init(objects: []Object) Simulation {
        return Simulation{
            .objects = objects,
        };
    }

    pub fn step(self: *Simulation, delta: f64) void {
        // Let's not have an accumulator for now and simply
        // allocate enough memory for the time being.
        var accs: [128]Vec2 = undefined;
        std.debug.print("\nStep with delta={}\n", .{delta});

        for (0..self.objects.len) |i| {
            accs[i] = self.computeExternalForces(i);
        }

        for (0..self.objects.len) |i| {
            var o = &self.objects[i];
            const acc = accs[i];
            const newVel = o.vel.add(acc.scale(delta));
            const newPos = o.pos.add(newVel.scale(delta));
            o.pos = newPos;
            o.vel = newVel;
            std.debug.print("objects[{}] = ({}, {}, {})\n", .{ i, newPos.x, newPos.y, newVel.len() });
        }
    }

    fn computeExternalForces(self: *Simulation, curIndex: u64) Vec2 {
        const co = self.objects[curIndex];
        var accSum = Vec2.zero();
        for (self.objects, 0..) |o, i| {
            if (i == curIndex) {
                continue;
            }

            const acc = co.computeGravitationalForce(o);
            accSum.x += acc.x;
            accSum.y += acc.y;
        }
        return accSum;
    }
};

const Object = @import("core.zig").Object;
const Vec2 = @import("core.zig").Vec2;
const std = @import("std");


// @mlesniak add tick here.
pub const Simulation = struct {
    objects: []Object,

    pub fn init(os: []Object) Simulation {
        return Simulation{
            .objects = os,
        };
    }

    pub fn step(self: *const Simulation, delta: f64) void {
        // Let's not have an accumulator for now and simply
        // allocate enough memory for the time being.
        var accs: [128]Vec2 = undefined;

        for (0..self.objects.len) |i| {
            accs[i] = self.computeExternalForces(i);
            // std.debug.print("acc[{}]={}\n", .{i, accs[i]});
        }

        for (0..self.objects.len) |i| {
            var o = &self.objects[i];
            const acc = accs[i];
            const newVel = o.vel.add(acc.scale(delta));
            const newPos = o.pos.add(newVel.scale(delta));

            if (o.tick > 16) {
                o.tick = 0;
                o.trail[o.trailIndex] = o.pos;
                o.trailIndex += 1;
                if (o.trailIndex == o.trail.len) {
                    o.trailIndex = 0;
                }
            } else {
                o.tick += 1;
            }

            o.pos = newPos;
            o.vel = newVel;
            // std.debug.print("objects[{}] = ({}, {}, {})\n", .{ i, newPos.x, newPos.y, newVel.len() });
        }
    }

    fn computeExternalForces(self: *const Simulation, curIndex: u64) Vec2 {
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
        return Vec2{
            .x = accSum.x / co.mass,
            .y = accSum.y / co.mass,
        };
    }
};

const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn t() !void {
    try stdout.print("hello world\n", .{});
}

const std = @import("std");
const expect = std.testing.expect;

const zf = @import("ziframe");

test "mem test" {
    const ColValue = struct {
        id: u16 = 3,
        age: u32,
    };

    const alloc = std.testing.allocator;
    var df = try zf.DataFrame(ColValue).fromCSV(alloc, "./tmp/test.csv", .{});
    defer df.deinit();

    std.debug.print("\n{}\n", .{df});
}

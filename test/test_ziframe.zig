const std = @import("std");
const expect = std.testing.expect;

test "simple check" {
    try expect(true);
}

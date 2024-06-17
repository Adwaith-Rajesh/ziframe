const std = @import("std");

const zf = @import("ziframe");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const ColValue = struct {
        id: u16 = 3,
        age: u32,
        marks: f64,
    };

    // var df = try zf.DataFrame(ColValue).fromCSV(alloc, "./tmp/test.csv", .{ .header = false });
    // defer df.deinit();

    // std.debug.print("\n{}\n", .{df});
    // std.debug.print("shape: {}\n", .{df.shape()});
    // std.debug.print("shape: {}\n", .{df.shape().size()});

    var df = zf.DataFrame(ColValue).init(alloc);
    defer df.deinit();

    try df.append(.{ .id = 1, .age = 10, .marks = 10 });
    try df.append(.{ .id = 2, .age = 20, .marks = 40 });
    try df.append(.{ .id = 3, .age = 30, .marks = 30 });
    try df.append(.{ .id = 4, .age = 40, .marks = 20 });
    try df.append(.{ .id = 5, .age = 50, .marks = 10 });

    std.debug.print("{}\n", .{df});

    const remove_odd_id = struct {
        pub fn in(row: ColValue) ?ColValue {
            if (row.id % 2 != 0) {
                return null;
            }

            return row;
        }
    }.in;

    var new_df = try zf.DataFrame(ColValue).fromDF(alloc, ColValue, df, remove_odd_id);
    defer new_df.deinit();

    std.debug.print("\n\n{}\n", .{new_df});
}

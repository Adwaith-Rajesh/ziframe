const std = @import("std");

const zf = @import("ziframe");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const ColValue = struct {
        id: u16 = 3,
        age: u32,
    };

    var df = zf.DataFrame(ColValue).init(alloc);
    defer df.deinit();

    try df.append(.{ .id = 10, .age = 10 });
    try df.append(.{ .id = 11, .age = 11 });
    try df.append(.{ .id = 12, .age = 14 });
    try df.append(.{ .id = 13, .age = 20 });
    try df.append(.{ .id = 14, .age = 19 });
    try df.append(.{ .age = 45 });

    // add a new col -> creates a new DF
    const NewCols = struct {
        id: u16 = 3,
        age: u32,
        height: u32,
    };

    const mapFn = struct {
        pub fn getHeight(row: ColValue) NewCols {
            return .{
                .id = row.id,
                .age = row.age,
                .height = @as(u32, @intCast(row.id)) + row.age,
            };
        }
    }.getHeight;

    var new_df = try zf.DataFrame(NewCols).fromDF(alloc, ColValue, df, mapFn);
    defer new_df.deinit();

    // std.debug.print("{}\n", .{df});
    for (new_df.rows()) |row| {
        std.debug.print("row: {any}\n", .{row});
    }

    const sqrFn = struct {
        pub fn sg(row: *NewCols) !void {
            row.*.height *= 2;
        }
    }.sg;

    try new_df.map(sqrFn);
    std.debug.print("\n{}\n", .{new_df});
}

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
    // const NewColVal = struct {
    //     id: u16 = 3,
    //     age: u32,
    //     height: f32,
    // };

    for (df.iter()) |row| {
        std.debug.print("row: {any}\n", .{row});
    }

    // var new_df = zf.DataFrame(NewCols).formPrev(ColValue, df, );

    // std.debug.print("{}\n", .{df});
}

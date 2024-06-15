const std = @import("std");
const meta = std.meta;
const stdout = std.io.getStdOut().writer();

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn DataFrame(comptime Columns: type) type {
    if (!(@typeInfo(Columns) == .Struct)) {
        @compileError("Columns must be of type struct, found " ++ @typeName(Columns));
    }

    const column_fields = meta.fields(Columns);

    // THE DATA FRAME
    return struct {
        data: _DataFrame,

        const Self = @This();

        const _DataFrame = ArrayList(Columns);

        /// returns an empty DataFrame
        pub fn init(alloc: Allocator) Self {
            return .{
                .data = _DataFrame.init(alloc),
            };
        }

        /// Add a new row to the DataFrame
        pub fn append(self: *Self, data: Columns) !void {
            try self.data.append(data);
        }

        /// release all memory allocated by the DataFrame
        pub fn deinit(self: Self) void {
            self.data.deinit();
        }

        /// format the DataFrame nicely
        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = options;
            _ = fmt;
            inline for (column_fields) |cf| {
                try writer.print("{s} ", .{cf.name});
            }
            try writer.print("\n", .{});

            for (self.data.items, 0..) |row, idx| {
                try writer.print("{} {any}\n", .{ idx, row });
            }
        }
    };
}

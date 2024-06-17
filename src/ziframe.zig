const std = @import("std");
const meta = std.meta;
const stdout = std.io.getStdOut().writer();

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const csv = @import("csv.zig");

const DataFrameShape = struct {
    rows: usize,
    cols: usize,

    const Self = @This();

    pub fn size(self: Self) usize {
        return self.rows * self.cols;
    }

    pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("{}x{}", .{ self.rows, self.cols });
    }
};

/// DataFrame.
/// Stores 2D data.
/// structure is immutable (i.e adding a new columns creates a new DataFrame)
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

        /// Create a new DF based on the prev.
        /// useful for adding and removing columns. ig
        pub fn fromDF(alloc: Allocator, T: type, prev: DataFrame(T), map_fn: fn (T) Columns) !Self {
            var new_df = Self.init(alloc);
            for (prev.rows()) |row| {
                try new_df.append(map_fn(row));
            }
            return new_df;
        }

        /// create a new DF using a CSV file
        pub fn fromCSV(alloc: Allocator, file_name: []const u8, csv_config: csv.CSVConfig) !Self {
            const file = try std.fs.cwd().openFile(file_name, .{});
            defer file.close();

            var new_df = Self.init(alloc);
            var csv_iterator = try csv.CsvToColumnIterator(std.fs.File.Reader, Columns).init(alloc, file.reader(), csv_config);
            defer csv_iterator.deinit();

            while (try csv_iterator.next()) |row| {
                try new_df.append(row);
            }

            return new_df;
        }

        /// returns the shape of the DataFrame
        pub fn shape(self: Self) DataFrameShape {
            return .{
                .rows = self.data.items.len,
                .cols = @typeInfo(Columns).Struct.fields.len,
            };
        }

        /// Add a new row to the DataFrame
        pub fn append(self: *Self, data: Columns) !void {
            try self.data.append(data);
        }

        /// get an iterator for the DataFrame.
        pub fn rows(self: Self) []Columns {
            return self.data.items;
        }

        /// Apply a function over the DataFrame
        pub fn map(self: *Self, map_fn: fn (*Columns) anyerror!void) !void {
            for (self.rows()) |*row| {
                try map_fn(row);
            }
        }

        /// release all memory allocated by the DataFrame
        pub fn deinit(self: Self) void {
            self.data.deinit();
        }

        /// format the DataFrame nicely
        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = options;
            _ = fmt;
            try writer.print("index ", .{});
            inline for (column_fields) |cf| {
                try writer.print("{s} ", .{cf.name});
            }
            try writer.print("\n", .{});

            for (self.data.items, 0..) |row, idx| {
                try writer.print("{} ", .{idx});
                inline for (column_fields) |cf| {
                    try writer.print(if (@typeInfo(cf.type) == .Float) " {:.7} " else " {any}", .{@field(row, cf.name)});
                }
                try writer.print("\n", .{});
            }
        }
    };
}

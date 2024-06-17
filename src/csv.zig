const std = @import("std");
const Allocator = std.mem.Allocator;

const bcsv = @import("bcsv");

/// converts the string from the CSV to the respective Type  obtained from the Column struct
fn parse(T: type, buf: []const u8) !T {
    const TypeInfo = @typeInfo(T);
    return switch (TypeInfo) {
        .Int => std.fmt.parseInt(T, buf, 10),
        .Float => std.fmt.parseFloat(T, buf),
        .Bool => std.mem.eql(u8, buf, "true"),
        .Enum => |en| {
            inline for (en.fields) |field| {
                if (std.mem.eql(u8, field, buf)) {
                    return @enumFromInt(field.value);
                }
            }
        },
        else => {
            @compileError("pare is not supported for the type, " ++ @typeName(T));
        },
    };
}

pub const CSVConfig = struct {
    col_sep: u8 = ',',
    row_sep: u8 = '\n',
    quote: u8 = '"',
    header: bool = true,
    buffer_size: usize = 4096,
};

pub fn CsvToColumnIterator(Reader: type, ColType: type) type {
    return struct {
        // col_type: type = ColType,
        cfg: CSVConfig,
        file_reader: Reader,

        alloc: Allocator,
        _read_buffer: []u8 = undefined,
        _csv_tokenizer: bcsv.CsvTokenizer(Reader),

        var _head_skipped = false;
        const _col_fields = @typeInfo(ColType).Struct.fields;
        const Self = @This();

        pub fn init(alloc: Allocator, reader: Reader, config: CSVConfig) !Self {
            const buff = try alloc.alloc(u8, config.buffer_size);
            return Self{
                .alloc = alloc,
                .file_reader = reader,
                .cfg = config,
                ._read_buffer = buff,
                ._csv_tokenizer = try bcsv.CsvTokenizer(Reader).init(reader, buff, .{
                    .col_sep = config.col_sep,
                    .row_sep = config.row_sep,
                    .quote = config.quote,
                }),
            };
        }

        pub fn next(self: *Self) !?ColType {
            if (self.cfg.header and !_head_skipped) { // there is a header section, we need to skip it
                while (try self._csv_tokenizer.next()) |token| {
                    if (token == .row_end) break;
                }
                // prevent header skip every time next is called
                _head_skipped = true;
            }

            var new_row = std.mem.zeroInit(ColType, .{});
            inline for (_col_fields) |field| {
                @field(new_row, field.name) = try parse(field.type, (try self._csv_tokenizer.next() orelse return null).field);
            }

            // discard the .row_end token
            _ = try self._csv_tokenizer.next() orelse return null;
            return new_row;
        }

        pub fn deinit(self: Self) void {
            self.alloc.free(self._read_buffer);
        }
    };
}

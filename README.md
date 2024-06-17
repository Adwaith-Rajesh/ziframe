# Ziframe

A minimal 'DataFrame' library in zig.

In it's current form it can only perform basic operations such as

- add rows
- add columns
- read from CSV file
- removing rows/cols (using fromDF())
- apply a function over the DataFrame
- get shape

---

### Why

- It's part of something big.
- I wanted a way to read CSV files in zig in a proper way

---

### Usage

#### Building

- `build.zig.zon`

```zig
.{
    ...
    .dependencies = .{
        .ziframe = .{
            .url = "https://github.com/Adwaith-Rajesh/ziframe/archive/refs/tags/v0.1.0.tar.gz",
            .hash = "you know how to get this :)",
        }
    }
    ...
}
```

- `build.zig`

```zig
pub fn build(b: *std.Build) void {
    ...

    const ziframe = b.dependency("ziframe", .{
        .optimize = optimize,
        .target = target,
    });

    const your_exe = b.addExecutable(.{
        .name = "you_exe",
        .root_source_file = b.path("path/to/source_file.zig"),
        .target = target,
        .optimize = optimize,
    });

    // add ziframe import
    your_exe.root_module.addImport("ziframe", ziframe.module("ziframe"));

    ...

}

```

### Using Ziframe

- `test.csv`

```csv
id,marks1,marks2
1,10.23,20.45
2,12.90,33.45
3,46,50
```

- `main.zig`

```zig
const std = @import("std");
const debug = std.debug;

const zf = @import("ziframe");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit()

    const alloc = gpa.allocator();

    // The columns of the DataFrame
    const DFColumns = struct {
        id: u32,
        marks1: f64,
        marks2: f64,
    };

    // Create an empty DataFrame
    // var df = zf.DataFrame(Columns).init(alloc);
    // defer df.deinit();

    // read test.csv a create a new DataFrame
    var df = try zf.DataFrame(DFColumns).fromCSV(alloc, "./test.csv", .{});
    defer df.deinit();

    debug.print("CSV file contents\n", .{});
    debug.print("{}\n", .{df});

    // adding a new row
    try df.append(.{ .id = 4, .marks1 = 10, .marks2 = 20 });
    debug.print("Add new row\n", .{});
    debug.print("{}\n", .{df});

    // Create a new DF with id and total marks from 'df'
    const TotalDFCols = struct {
        id: u32,
        total: f64,
    };

    // function on how to create the new df
    const total = struct {
        fn in(row: DFColumns) ?TotalDFCols {
            return .{
                .id = row.id,
                .total = row.marks1 + row.marks2,
            };
        }
    }.in;

    var total_df = try zf.DataFrame(TotalDFCols).fromDF(alloc, DFColumns, df, total);
    defer total_df.deinit();

    debug.print("New DataFrame with the total columns\n", .{});
    debug.print("{}\n", .{total_df});

    // filtering
    // filter DataFrame, display only even ids

    const filterEven = struct {
        fn in(row: TotalDFCols) ?TotalDFCols {
            if (row.id % 2 != 0) return null;
            return row;
        }
    }.in;

    var even_df = try zf.DataFrame(TotalDFCols).fromDF(alloc, TotalDFCols, total_df, filterEven);
    defer even_df.deinit();

    debug.print("DataFrame with only even ids\n", .{});
    debug.print("{}\n", .{even_df});

    // printing the shape and size
    debug.print("shape of df: {} size of df: {}\n", .{ df.shape(), df.shape().size() });
    debug.print("shape of total_df: {} size of df: {}\n", .{ total_df.shape(), total_df.shape().size() });
    debug.print("shape of even_df: {} size of df: {}\n", .{ even_df.shape(), even_df.shape().size() });

    // Map Function
    // set total = 50 where id = 2
    const update = struct {
        //             pointer to the row
        pub fn in(row: *TotalDFCols) !void {
            if (row.*.id == 2) {
                row.*.total = 50;
            }
        }
    }.in;

    try even_df.map(update);
    debug.print("\nset total = 50 where id = 2\n", .{});
    debug.print("{}\n", .{even_df});
}

```

- output
<details>
<summary><b>Output</b></summary>

```commandline

CSV file contents
index id marks1 marks2
0  1 10.2300000  20.4500000
1  2 12.9000000  33.4500000
2  3 46.0000000  50.0000000

Add new row
index id marks1 marks2
0  1 10.2300000  20.4500000
1  2 12.9000000  33.4500000
2  3 46.0000000  50.0000000
3  4 10.0000000  20.0000000

New DataFrame with the total columns
index id total
0  1 30.6800000
1  2 46.3500000
2  3 96.0000000
3  4 30.0000000

DataFrame with only even ids
index id total
0  2 46.3500000
1  4 30.0000000

shape of df: 4x3 size of df: 12
shape of total_df: 4x2 size of df: 8
shape of even_df: 2x2 size of df: 4

set total = 50 where id = 2
index id total
0  2 50.0000000
1  4 30.0000000
```

</details>

---

### More docs in the future - maybe :)

### Bye..
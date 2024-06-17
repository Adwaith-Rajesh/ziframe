# Ziframe

A minimal 'DataFrame' library in zig.

In it's current form it can only perform basic operations such as

- add rows
- add columns
- read from CSV file
- removing rows/cols (using fromDF())
- apply a function over the DataFrame
- get shape

### Why

- It's part of something big.
- I wanted a way to read CSV files in zig in a proper way

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

#### Using Ziframe

```zig

```

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // dependencies
    // https://github.com/beho/zig-csv
    const bcsv = b.dependency("bcsv", .{ // beho-csv
        .optimize = optimize,
        .target = target,
    });

    const zf_mod = b.addModule("ziframe", .{
        .root_source_file = b.path("src/ziframe.zig"),
        .optimize = optimize,
        .target = target,
    });

    // add csv mod
    zf_mod.addImport("bcsv", bcsv.module("zig-csv"));

    const sanity_exe = b.addExecutable(.{
        .name = "sanity",
        .root_source_file = b.path("test/sanity.zig"),
        .target = target,
        .optimize = optimize,
    });

    sanity_exe.root_module.addImport("ziframe", zf_mod);
    const run_sanity = b.addRunArtifact(sanity_exe);

    // sanity step
    const run_step = b.step("sanity", "run sanity check");
    run_step.dependOn(&run_sanity.step);

    // simple test file
    const simple_test = b.addTest(.{
        .name = "simple_test",
        .root_source_file = b.path("test/test_ziframe.zig"),
        .optimize = optimize,
        .target = target,
    });

    const run_simple_test = b.addRunArtifact(simple_test);

    // run test
    const run_test = b.step("test", "run the test");
    run_test.dependOn(&run_simple_test.step);
}

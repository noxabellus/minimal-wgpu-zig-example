const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const wgpu_linux_x64 = b.dependency("wgpu_native_linux_x64", .{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe = b.addExecutable(.{
        .name = "wgpu_zig",
        .root_module = exe_mod,
    });

    exe_mod.addCSourceFile(.{ .file = b.path("c/stb_image.c") });
    exe_mod.addLibraryPath(wgpu_linux_x64.path("lib/"));
    exe_mod.linkSystemLibrary("wgpu_native", .{});
    exe_mod.linkSystemLibrary("glfw", .{});
    exe_mod.linkSystemLibrary("m", .{});
    exe_mod.linkSystemLibrary("dl", .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const check_step = b.step("check", "Semantic analysis");
    check_step.dependOn(&exe_unit_tests.step);
}

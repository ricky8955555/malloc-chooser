const builtin = @import("builtin");
const std = @import("std");

const blacklist_malloc_libs = [_][]const u8{"jemalloc"};
const malloc_impl: [*:0]const u8 = switch (builtin.target.cpu.arch) {
    .x86_64 => "/usr/lib64/libmimalloc.so",
    .x86 => "/usr/lib/libmimalloc.so",
    else => @compileError("Unsupported CPU architecture."),
};

fn detectAndLoad() !void {
    std.posix.dl_iterate_phdr(void{}, error{HasBlacklistLibrary}, struct {
        fn callback(info: *std.posix.dl_phdr_info, size: usize, ctx: void) !void {
            _ = size;
            _ = ctx;

            if (info.name) |c_name| {
                const name: []const u8 = std.mem.span(c_name);
                inline for (blacklist_malloc_libs) |expect| {
                    if (std.mem.find(u8, name, expect) != null) {
                        return error.HasBlacklistLibrary;
                    }
                }
            }
        }
    }.callback) catch return;

    const handle = std.c.dlopen(malloc_impl, .{ .LAZY = true, .GLOBAL = true });
    if (handle == null) return error.LoadLibraryFailed;
}

fn startup() callconv(.c) void {
    detectAndLoad() catch |err| std.debug.print("[malloc_chooser] Failed to initialize: {}", .{err});
}

export const _startup_init_array_entry linksection(".init_array") = &startup;

// zig run loader.zig -lc

const std = @import("std");
const c = @cImport({
    @cInclude("sys/mman.h");
});

pub fn main() !void {
    const file = try std.fs.cwd().openFile("shellcode.bin", .{});
    defer file.close();

    const size = (try file.stat()).size;
    std.debug.print("Shellcode size: {} bytes\n", .{size});

    // Используем libc mmap
    const mem = c.mmap(
        null,
        size,
        c.PROT_READ | c.PROT_WRITE | c.PROT_EXEC,
        c.MAP_PRIVATE | c.MAP_ANONYMOUS,
        -1,
        0,
    );

    if (mem == c.MAP_FAILED) {
        std.debug.print("mmap failed\n", .{});
        return error.MMapFailed;
    }
    defer _ = c.munmap(mem, size);

    // Читаем shellcode
    _ = try file.readAll(@as([*]u8, @ptrCast(mem))[0..size]);
    
    std.debug.print("Executing shellcode...\n", .{});

    const func: *const fn () callconv(.c) void = @ptrCast(mem);
    func();
}

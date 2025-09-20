
// zig assembly syntax

// asm [volatile] (
//     "assembly template"
//     :
//     outputs
//     :
//     inputs
//     :
//     clobbers
// )

inline fn
syscall1(number: usize, arg1: usize) usize {
    return asm volatile (
        "syscall"
        : [ret] "={rax}" (-> usize),
        : [number] "{rax}" (number),
          [arg1] "{rdi}" (arg1),
        : .{ .rcx = true, .r11 = true });
}

inline fn
syscall3(number: usize, arg1: usize, arg2: usize, arg3: usize) usize {
    return asm volatile (
        "syscall"
        : [ret] "={rax}" (-> usize),
        : [number] "{rax}" (number),
          [arg1] "{rdi}" (arg1),
          [arg2] "{rsi}" (arg2),
          [arg3] "{rdx}" (arg3),
        : .{ .rcx = true, .r11 = true });
}

inline fn
exit(status: usize) noreturn {
    _ = syscall1(60, status);
    unreachable;
}

inline fn
write(fd: usize, buf: [*]u8, count: usize) usize {
    return syscall3(1, fd, @intFromPtr(buf), count);
}

export fn
_start() noreturn {
    var msg = [_]u8{
        'h', 'e', 'l', 'l', 'o', ' ',
        's', 'a', 'i', 'l', 'o', 'r', '!',
        0x0a, 0x00
    };

    var i: usize = 0;
    while (i < 10) : (i += 1) {
        _ = write(1, &msg, msg.len);
    }

    exit(0);
}

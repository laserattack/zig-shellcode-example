inline fn exit(status: usize) noreturn {
    _ = asm volatile (
        \\mov $60, %%rax
        \\mov %[status], %%rdi
        \\syscall
        :
        : [status] "{rdi}" (status)
        : .{ .rax = true, .rcx = true, .r11 = true }
    );
    unreachable;
}

// assemvly syntax in zig

// asm [volatile] (
//     "assembly template"
//     :
//     outputs
//     :
//     inputs
//     :
//     clobbers
// )

inline fn write(fd: usize, buf: [*]u8, count: usize) usize {
    return asm volatile (
        \\mov $1, %%rax
        \\mov %[fd], %%rdi
        \\mov %[buf], %%rsi
        \\mov %[count], %%rdx
        \\syscall
        :
        [ret] "={rax}" (-> usize) // return value syntax
        :
        [fd] "{rdi}" (fd),
        [buf] "{rsi}" (buf),
        [count] "{rdx}" (count)
        :
        // affected registers
        .{ .rax = true, .rcx = true, .r11 = true }
    );
}

export fn _start() noreturn {
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

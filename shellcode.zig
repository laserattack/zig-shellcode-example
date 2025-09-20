inline fn exit(status: u64) noreturn {
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

inline fn write(fd: u64, buf: [*]const u8, count: u64) usize {
    return asm volatile (
        \\mov $1, %%rax
        \\mov %[fd], %%rdi
        \\mov %[buf], %%rsi
        \\mov %[count], %%rdx
        \\syscall
        :
        [ret] "={rax}" (-> usize)
        :
        [fd] "{rdi}" (fd),
        [buf] "{rsi}" (buf),
        [count] "{rdx}" (count)
        :
        .{ .rax = true, .rcx = true, .r11 = true }
    );
}

export fn _start() noreturn {
    var msg = [_]u8{
        'h', 'e', 'l', 'l', 'o', ' ',
        's', 'a', 'i', 'l', 'o', 'r', '!',
        0x0a, 0x00
    };
    
    var i: u32 = 0;
    while (i < 10) : (i += 1) {
        _ = write(1, &msg, msg.len);
    }

    exit(0);
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    // Компиляция в объектный файл
    const compile_step = b.step("compile", "Compile to object file");
    const compile_cmd = b.addSystemCommand(&.{
        "zig", "build-obj",
        "shellcode.zig",
        "-fno-entry",
        "-O", "ReleaseSmall", 
        "-target", "x86_64-linux",
        "-fstrip",
    });
    compile_step.dependOn(&compile_cmd.step);

    // Линковка в исполняемый файл (полный)
    const link_step = b.step("link", "Link to executable");
    const link_cmd = b.addSystemCommand(&.{
        "ld",
        "-o", "shellcode.elf",
        "shellcode.o", 
        "-nostdlib",
    });
    link_cmd.step.dependOn(&compile_cmd.step);
    link_step.dependOn(&link_cmd.step);

    // Создание чистого shellcode (только .text)
    const extract_step = b.step("extract", "Extract .text section to binary");
    const extract_cmd = b.addSystemCommand(&.{
        "objcopy",
        "-O", "binary",
        "-j", ".text",
        "shellcode.o",
        "shellcode.bin",
    });
    extract_cmd.step.dependOn(&compile_cmd.step);
    extract_step.dependOn(&extract_cmd.step);

    // Установка зависимостей
    b.default_step.dependOn(compile_step);
    b.default_step.dependOn(link_step);
    b.default_step.dependOn(extract_step);

    // Очистка
    const clean_step = b.step("clean", "Clean build artifacts");
    const clean_cmd = b.addSystemCommand(&.{
        "rm", "-f",
        "shellcode.o",
        "shellcode.elf", 
        "shellcode.bin",
    });
    clean_step.dependOn(&clean_cmd.step);
}

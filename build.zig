const std = @import("std");

pub fn build(b: *std.Build) void {

    // Компиляция в объектный файл
    const compile_cmd = b.addSystemCommand(&.{
        "zig", "build-obj",
        "shellcode.zig",
        "-fno-entry",
        "-O", "ReleaseSmall", 
        "-target", "x86_64-linux",
        "-fstrip",
    });

    // Чтобы можно было компилировать через zig build compile
    const compile_step = b.step("compile", "Compile to object file");
    compile_step.dependOn(&compile_cmd.step);



    // Линковка в исполняемый файл
    const link_cmd = b.addSystemCommand(&.{
        "ld",
        "-o", "shellcode.elf",
        "shellcode.o", 
        "-nostdlib",
    });
    // Линковка только если уже произошла компилция
    link_cmd.step.dependOn(&compile_cmd.step);

    // Чтобы можно было линковать через zig build link
    const link_step = b.step("link", "Link to executable");
    link_step.dependOn(&link_cmd.step);



    // Создание чистого шеллкода (только секция .text)
    const extract_cmd = b.addSystemCommand(&.{
        "objcopy",
        "-O", "binary",
        "-j", ".text",
        "shellcode.o",
        "shellcode.bin",
    });
    // Создание чистого шеллкода возможно
    // только если уже произошла компиляция
    extract_cmd.step.dependOn(&compile_cmd.step);

    // Чтобы можно было создавать чистый шеллкод через zig build extract
    const extract_step = b.step("extract", "Extract .text section to binary");
    extract_step.dependOn(&extract_cmd.step);



    // Очистка
    const clean_cmd = b.addSystemCommand(&.{
        "rm", "-f",
        "shellcode.o",
        "shellcode.elf", 
        "shellcode.bin",
    });

    // Очистка через zig build clean
    const clean_step = b.step("clean", "Clean build artifacts");
    clean_step.dependOn(&clean_cmd.step);



    // Тестирование
    const test_cmd = b.addSystemCommand(&.{
        "zig", "run",
        "loader.zig",
        "-lc", // линковка с libc
    });
    test_cmd.step.dependOn(&extract_cmd.step);

    // Чтобы можно было тестировать через zig build test
    const test_step = b.step("test", "Test shellcode by running loader.zig");
    test_step.dependOn(&test_cmd.step);



    // Сборка
    // Выполняемая через zig build
    b.default_step.dependOn(compile_step);
    b.default_step.dependOn(link_step);
    b.default_step.dependOn(extract_step);
}

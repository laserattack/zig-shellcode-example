const std = @import("std");

pub fn build(b: *std.Build) void {

    const shellcode_base = "shellcode";
    const loader_base = "loader";


    const source_file = shellcode_base ++ ".zig";
    const object_file = shellcode_base ++ ".o";
    const elf_file = shellcode_base ++ ".elf";
    const bin_file = shellcode_base ++ ".bin";
    const loader_file = loader_base ++ ".zig";



    // Компиляция в объектный файл
    const compile_cmd = b.addSystemCommand(&.{
        "zig", "build-obj",
        source_file,
        "-fno-entry",
        "-O", "ReleaseSmall", 
        "-target", "x86_64-linux",
        "-fstrip",
    });

    // Чтобы было доступно через zig build compile
    const compile_step = b.step("compile", "Compile to object file");
    compile_step.dependOn(&compile_cmd.step);



    // Линковка в исполняемый файл
    const link_cmd = b.addSystemCommand(&.{
        "ld",
        "-o", elf_file,
        object_file, 
        "-nostdlib",
    });
    link_cmd.step.dependOn(&compile_cmd.step);

    // Чтобы было доступно через zig build link
    const link_step = b.step("link", "Link to executable");
    link_step.dependOn(&link_cmd.step);



    // Создание чистого шеллкода (только секция .text)
    const extract_cmd = b.addSystemCommand(&.{
        "objcopy",
        "-O", "binary",
        "-j", ".text",
        object_file,
        bin_file,
    });
    extract_cmd.step.dependOn(&compile_cmd.step);

    // Чтобы было доступно через zig build extract
    const extract_step = b.step("extract", "Extract .text section to binary");
    extract_step.dependOn(&extract_cmd.step);



    // Очистка
    const clean_cmd = b.addSystemCommand(&.{
        "rm", "-f",
        object_file,
        elf_file, 
        bin_file,
    });

    // Чтобы было доступно через zig build clean
    const clean_step = b.step("clean", "Clean build artifacts");
    clean_step.dependOn(&clean_cmd.step);



    // Тестирование
    const test_cmd = b.addSystemCommand(&.{
        "zig", "run",
        loader_file,
        "-lc", // линковка с libc
    });
    test_cmd.step.dependOn(&extract_cmd.step);

    // Чтобы было доступно через zig build test
    const test_step = b.step("test", "Test shellcode by running loader.zig");
    test_step.dependOn(&test_cmd.step);



    // Выполняемое через zig build
    b.default_step.dependOn(compile_step);
    b.default_step.dependOn(link_step);
    b.default_step.dependOn(extract_step);
}

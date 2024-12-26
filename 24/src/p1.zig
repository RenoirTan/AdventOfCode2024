const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const argv = try std.process.argsAlloc(allocator);
    defer allocator.free(argv);

    if (argv.len < 2) {
        std.debug.print("No file included!\n", .{});
        std.process.exit(1);
    }

    var grove = root.Grove.init(allocator);
    defer grove.deinit();

    var file = try std.fs.cwd().openFile(argv[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // var iter = grove.indices.keyIterator();
        // while (iter.next()) |k| {
        //     const key = k.*;
        //     std.debug.print("Existing: {s}\n", .{key});
        // }
        _ = try grove.parseInstruction(line);
    }

    // _ = try grove.parseInstruction("x00: 1");
    // _ = try grove.parseInstruction("x01: 1");
    // _ = try grove.parseInstruction("x02: 1");
    // _ = try grove.parseInstruction("y00: 0");
    // _ = try grove.parseInstruction("y01: 1");
    // _ = try grove.parseInstruction("y02: 0");
    // _ = try grove.parseInstruction("x00 AND y00 -> z00");
    // _ = try grove.parseInstruction("x01 XOR y01 -> z01");
    // _ = try grove.parseInstruction("x02 OR y02 -> z02");

    var variables = try grove.solve(allocator);
    defer variables.deinit();

    var x: u64 = 0;
    var iter = variables.keyIterator();
    while (iter.next()) |k| {
        const key = k.*;
        if (key[0] != 'z') {
            continue;
        }
        const shifted = try std.fmt.parseInt(u6, key[1..3], 10);
        const value = @as(u64, variables.get(key) orelse unreachable);
        x |= value << shifted;
        // std.debug.print("{s} -> {d}\n", .{ key, value });
    }
    std.debug.print("{d}\n", .{x});
}

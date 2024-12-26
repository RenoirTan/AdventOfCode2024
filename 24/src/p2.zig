const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var bad = [_][]const u8{ "z14", "hbk", "z18", "kvn", "z23", "dbb", "cvh", "tfn" };
    std.sort.heap([]const u8, &bad, {}, struct {
        fn cmp(_: void, a: []const u8, b: []const u8) bool {
            var i: usize = 0;
            while (true) {
                if (a[i] != b[i]) {
                    return a[i] < b[i];
                } else if (a[i] == 0) {
                    return false;
                } else {
                    i += 1;
                }
            }
        }
    }.cmp);
    const result = try std.mem.join(allocator, ",", &bad);
    defer allocator.free(result);
    std.debug.print("{s}\n", .{result});
}

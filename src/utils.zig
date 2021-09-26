const std = @import("std");

// TODO: pass allocator and still be C ABI compliant?

pub fn toSlice(c_string: [*:0]const u8) []const u8 {
    var c_slice: [:0]const u8 = std.mem.span(c_string);

    return c_slice[0..c_slice.len];
}

pub fn toNullTerminated(allocator: *std.mem.Allocator, string: []const u8) ?[:0]const u8 {
    return allocator.dupeZ(u8, string) catch null;
}

// TODO: maybe use [:0]u8 throughout so we don't have to do this
pub fn toCString(allocator: *std.mem.Allocator, string: []const u8) ?[*:0]const u8 {
    var c_string: ?[]u8 = allocator.dupeZ(u8, string) catch null;

    if (c_string == null) {
        return null;
    }

    return @ptrCast([*:0]u8, c_string.?);
}
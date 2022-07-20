const builtin = @import("builtin");

pub const Config = .{
    .debug = builtin.mode == .Debug and false,
    .debug_stack = builtin.mode == .Debug and false,
    .debug_gc = builtin.mode == .Debug and false,
    .debug_current_instruction = builtin.mode == .Debug and false,
    .debug_perf = true,
    .debug_stop_on_report = builtin.mode == .Debug and true,
    .debug_placeholders = builtin.mode == .Debug and false,
};

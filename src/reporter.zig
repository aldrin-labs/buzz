const std = @import("std");
const assert = std.debug.assert;
const Token = @import("./token.zig").Token;
const o = @import("obj.zig");
const ObjTypeDef = o.ObjTypeDef;
const PlaceholderDef = o.PlaceholderDef;

const Self = @This();

// Inspired by https://github.com/zesterer/ariadne
pub const ReportKind = enum {
    @"error",
    warning,
    hint,

    pub fn color(self: ReportKind) u8 {
        return switch (self) {
            .@"error" => 31,
            .warning => 33,
            .hint => 34,
        };
    }

    pub fn name(self: ReportKind) []const u8 {
        return switch (self) {
            .@"error" => "Error",
            .warning => "Warning",
            .hint => "Note",
        };
    }

    pub fn nameLower(self: ReportKind) []const u8 {
        return switch (self) {
            .@"error" => " error",
            .warning => " warning",
            .hint => " note",
        };
    }
};

pub const Note = struct {
    kind: ReportKind = .hint,
    message: []const u8,
};

pub const ReportItem = struct {
    location: Token,
    kind: ReportKind = .@"error",
    message: []const u8,

    pub const SortContext = struct {};

    pub fn lessThan(_: SortContext, lhs: ReportItem, rhs: ReportItem) bool {
        return lhs.location.line < rhs.location.line or (lhs.location.line == rhs.location.line and lhs.location.column < rhs.location.column);
    }
};

pub const ReportOptions = struct {
    surrounding_lines: usize = 2,
    and_stop: bool = false,
};

pub const Report = struct {
    message: []const u8,
    items: []const ReportItem,
    notes: []const Note = &[_]Note{},
    options: ReportOptions = .{},

    pub inline fn reportStderr(self: *Report, reporter: *Self) !void {
        return self.report(reporter, std.io.getStdErr().writer());
    }

    pub fn report(self: *Report, reporter: *Self, out: anytype) !void {
        assert(self.items.len > 0);

        // Print main error message
        const main_item = self.items[0];

        try out.print(
            "\n{s}:{}:{}: \x1b[{d}m{s}{s}:\x1b[0m {s}\n",
            .{
                main_item.location.script_name,
                main_item.location.line + 1,
                main_item.location.column,
                main_item.kind.color(),
                if (reporter.error_prefix) |prefix|
                    prefix
                else
                    "",
                if (reporter.error_prefix != null)
                    main_item.kind.nameLower()
                else
                    main_item.kind.name(),
                self.message,
            },
        );

        // Print items

        // Group items by files
        var reported_files = std.StringArrayHashMap(std.ArrayList(ReportItem)).init(reporter.allocator);
        defer {
            var it = reported_files.iterator();
            while (it.next()) |kv| {
                kv.value_ptr.*.deinit();
            }
            reported_files.deinit();
        }

        for (self.items) |item| {
            if (reported_files.get(item.location.script_name) == null) {
                try reported_files.put(
                    item.location.script_name,
                    std.ArrayList(ReportItem).init(reporter.allocator),
                );
            }

            try reported_files.getEntry(item.location.script_name).?.value_ptr.append(item);
        }

        var file_it = reported_files.iterator();
        while (file_it.next()) |file_entry| {
            if (reported_files.count() > 1) {
                try out.print("       \x1b[2m╭─\x1b[0m \x1b[4m{s}\x1b[0m\n", .{file_entry.key_ptr.*});
            }

            // Sort items by location in the source
            std.sort.insertion(
                ReportItem,
                file_entry.value_ptr.items,
                ReportItem.SortContext{},
                ReportItem.lessThan,
            );

            var reported_lines = std.AutoArrayHashMap(usize, std.ArrayList(ReportItem)).init(reporter.allocator);
            defer {
                var it = reported_lines.iterator();
                while (it.next()) |kv| {
                    kv.value_ptr.*.deinit();
                }
                reported_lines.deinit();
            }

            for (file_entry.value_ptr.items) |item| {
                if (reported_lines.get(item.location.line) == null) {
                    try reported_lines.put(
                        item.location.line,
                        std.ArrayList(ReportItem).init(reporter.allocator),
                    );
                }

                try reported_lines.getEntry(item.location.line).?.value_ptr.append(item);
            }

            var previous_line: ?usize = null;
            const keys = reported_lines.keys();
            for (keys, 0..) |line, index| {
                const next_line = if (index < keys.len - 1) keys[index + 1] else null;
                const report_items = reported_lines.get(line).?;

                assert(report_items.items.len > 0);

                // Does it overlap with previous reports, if so don't show lines before again
                var overlapping_before: i64 = if (previous_line) |previous|
                    @as(i64, @intCast(previous + self.options.surrounding_lines)) - @as(i64, @intCast(line - @min(line, self.options.surrounding_lines))) + 1
                else
                    0;

                // Is there a gap between two report items?
                if (overlapping_before < 0) {
                    try out.print("       \x1b[2m ...\x1b[0m\n", .{});
                }

                overlapping_before = @max(overlapping_before, 0);

                var before = @as(i64, @intCast(self.options.surrounding_lines)) - overlapping_before;
                before = @max(0, before);

                const after = if (next_line) |next|
                    if (next <= (line + self.options.surrounding_lines))
                        (line + self.options.surrounding_lines) - next + 1
                    else
                        self.options.surrounding_lines
                else
                    self.options.surrounding_lines;

                const lines = try report_items.items[0].location.getLines(
                    reporter.allocator,
                    @intCast(before),
                    after,
                );
                defer lines.deinit();

                var l: usize = line - @min(line, @as(usize, @intCast(before)));
                for (lines.items, 0..) |src_line, line_index| {
                    if (l != line) {
                        try out.print("\x1b[2m", .{});
                    }

                    try out.print(
                        " {: >5} {s} {s}\n\x1b[0m",
                        .{
                            l + 1,
                            if (line_index == 0 and (reported_files.count() == 1 or index > 0))
                                "╭─"
                            else if (line_index == lines.items.len - 1)
                                "╰─"
                            else
                                "│ ",
                            src_line,
                        },
                    );

                    if (l == line) {
                        // Print error cursors
                        try out.print("       \x1b[2m┆ \x1b[0m ", .{});
                        var column: usize = 0;
                        for (report_items.items) |item| {
                            const indent = if (item.location.column > 0)
                                item.location.column - 1 - @min(column, item.location.column - 1)
                            else
                                0;
                            try out.writeByteNTimes(' ', indent);

                            if (item.location.lexeme.len > 1) {
                                try out.print("\x1b[{d}m╭", .{item.kind.color()});
                            } else {
                                try out.print("\x1b[{d}m┬", .{item.kind.color()});
                            }
                            var i: usize = 0;
                            while (i < item.location.lexeme.len - 1) : (i += 1) {
                                try out.print("─", .{});
                            }
                            try out.print("\x1b[0m", .{});

                            column += indent + item.location.lexeme.len;
                        }

                        _ = try out.write("\n");

                        // Print error messages
                        for (report_items.items) |item| {
                            try out.print("       \x1b[2m┆ \x1b[0m ", .{});
                            try out.writeByteNTimes(' ', if (item.location.column > 0)
                                item.location.column - 1
                            else
                                0);
                            try out.print(
                                "\x1b[{d}m╰─ {s}\x1b[0m\n",
                                .{
                                    item.kind.color(),
                                    item.message,
                                },
                            );
                        }
                    }

                    l += 1;
                }

                previous_line = line;
            }
        }

        // Print notes
        for (self.notes) |note| {
            try out.print(
                "\x1b[{d}m{s}:\x1b[0m {s}\n",
                .{
                    note.kind.color(),
                    note.kind.name(),
                    note.message,
                },
            );
        }

        if (self.options.and_stop) {
            std.os.exit(1);
        }
    }
};

allocator: std.mem.Allocator,
panic_mode: bool = false,
had_error: bool = false,
error_prefix: ?[]const u8 = null,

pub fn report(self: *Self, token: Token, message: []const u8) void {
    self.panic_mode = true;
    self.had_error = true;

    var error_report = Report{
        .message = message,
        .items = &[_]ReportItem{
            ReportItem{
                .location = token,
                .message = message,
            },
        },
        .notes = &[_]Note{},
    };

    error_report.reportStderr(self) catch @panic("Unable to report error");
}

pub fn reportErrorAt(self: *Self, token: Token, message: []const u8) void {
    if (self.panic_mode) {
        return;
    }

    self.report(token, message);
}

pub fn reportErrorFmt(self: *Self, token: Token, comptime fmt: []const u8, args: anytype) void {
    var message = std.ArrayList(u8).init(self.allocator);
    defer message.deinit();

    var writer = message.writer();
    writer.print(fmt, args) catch @panic("Unable to report error");

    self.reportErrorAt(token, message.items);
}

pub fn reportWithOrigin(self: *Self, at: Token, decl_location: Token, comptime fmt: []const u8, args: anytype, declared_message: ?[]const u8) void {
    var message = std.ArrayList(u8).init(self.allocator);
    defer message.deinit();

    var writer = message.writer();
    writer.print(fmt, args) catch @panic("Unable to report error");

    var decl_report = Report{
        .message = message.items,
        .items = &[_]ReportItem{
            .{
                .location = at,
                .kind = .@"error",
                .message = message.items,
            },
            .{
                .location = decl_location,
                .kind = .hint,
                .message = declared_message orelse "declared here",
            },
        },
    };

    self.panic_mode = true;
    self.had_error = true;

    decl_report.reportStderr(self) catch @panic("Could not report error");
}

pub fn reportTypeCheck(
    self: *Self,
    expected_location: ?Token,
    expected_type: *ObjTypeDef,
    actual_location: Token,
    actual_type: *ObjTypeDef,
    message: []const u8,
) void {
    var actual_message = std.ArrayList(u8).init(self.allocator);
    defer actual_message.deinit();
    var writer = &actual_message.writer();

    writer.print("{s}: got type `", .{message}) catch @panic("Unable to report error");
    actual_type.toString(writer) catch @panic("Unable to report error");
    writer.writeAll("`") catch @panic("Unable to report error");

    var expected_message = std.ArrayList(u8).init(self.allocator);
    defer expected_message.deinit();

    if (expected_location != null) {
        writer = &expected_message.writer();
    }

    writer.writeAll("expected `") catch @panic("Unable to report error");

    expected_type.toString(writer) catch @panic("Unable to report error");
    writer.writeAll("`") catch @panic("Unable to report error");

    var full_message = if (expected_location == null) actual_message else std.ArrayList(u8).init(self.allocator);
    defer {
        if (expected_location != null) {
            full_message.deinit();
        }
    }
    if (expected_location != null) {
        full_message.writer().print("{s}, {s}", .{ actual_message.items, expected_message.items }) catch @panic("Unable to report error");
    }

    var check_report = if (expected_location) |location|
        Report{
            .message = full_message.items,
            .items = &[_]ReportItem{
                .{
                    .location = actual_location,
                    .kind = .@"error",
                    .message = actual_message.items,
                },
                .{
                    .location = location,
                    .kind = .hint,
                    .message = expected_message.items,
                },
            },
        }
    else
        Report{
            .message = full_message.items,
            .items = &[_]ReportItem{
                .{
                    .location = actual_location,
                    .kind = .hint,
                    .message = actual_message.items,
                },
            },
        };

    self.panic_mode = true;
    self.had_error = true;

    check_report.reportStderr(self) catch @panic("Could not report error");
}

// Got to the root placeholder and report it
pub fn reportPlaceholder(self: *Self, placeholder: PlaceholderDef) void {
    if (placeholder.parent) |parent| {
        if (parent.def_type == .Placeholder) {
            self.reportPlaceholder(parent.resolved_type.?.Placeholder);
        }
    } else {
        // Should be a root placeholder with a name
        assert(placeholder.name != null);
        self.reportErrorFmt(placeholder.where, "`{s}` is not defined", .{placeholder.name.?.string});
    }
}

test "multiple error on one line" {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

    var reporter = Self{
        .allocator = gpa.allocator(),
    };

    const source =
        \\| Say hello
        \\fun hello() > void {
        \\    callSomething(true, complex: 12);
        \\    return null;
        \\}
        \\
        \\fun something() > int {
        \\    foreach (int i, str char in "hello") {
        \\        if (i % 2 == 0) {
        \\            print("yes");
        \\            return i;
        \\        }
        \\    }
        \\
        \\    return -1;
        \\}
    ;

    var bad = Report{
        .message = "This could have been avoided if you were not a moron",
        .notes = &[_]Note{
            .{ .message = "This could have been avoided if you were not a moron" },
        },
        .items = &[_]ReportItem{
            .{
                .location = Token{
                    .source = source,
                    .script_name = "test",
                    .token_type = .Identifier,
                    .lexeme = "callSomething",
                    .line = 2,
                    .column = 5,
                },
                .kind = .@"error",
                .message = "This is so wrong",
            },
            .{
                .location = Token{
                    .source = source,
                    .script_name = "test",
                    .token_type = .Identifier,
                    .lexeme = "true",
                    .line = 2,
                    .column = 19,
                },
                .kind = .hint,
                .message = "This is also wrong",
            },
            .{
                .location = Token{
                    .source = source,
                    .script_name = "test",
                    .token_type = .Identifier,
                    .lexeme = "complex",
                    .line = 2,
                    .column = 25,
                },
                .kind = .warning,
                .message = "This is terribly wrong",
            },
            .{
                .location = Token{
                    .source = source,
                    .script_name = "test",
                    .token_type = .Identifier,
                    .lexeme = "print",
                    .line = 9,
                    .column = 13,
                },
                .kind = .hint,
                .message = "This was correct here",
            },
        },
    };

    try bad.reportStderr(&reporter);
}
const std = @import("std");
const clap = @import("clap");

const Command = enum {
    init,
    deploy,
    test,
    build,
};

const Template = enum {
    agent,
    trading,
    yield,
    custom,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Define command line parameters
    const params = comptime clap.parseParamsComptime(
        \\-h, --help     Display this help and exit
        \\-v, --version  Display version and exit
        \\-t, --template <str>  Project template (agent/trading/yield/custom)
        \\<str>...
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    // Handle help and version flags
    if (res.args.help == 1) {
        try printUsage();
        return;
    }

    if (res.args.version == 1) {
        try std.io.getStdOut().writer().print("buzz-cli version 0.1.0\n", .{});
        return;
    }

    // Parse command and arguments
    if (res.positionals.len == 0) {
        try printUsage();
        return;
    }

    const cmd_str = res.positionals[0];
    const cmd = std.meta.stringToEnum(Command, cmd_str) orelse {
        std.debug.print("Unknown command: {s}\n", .{cmd_str});
        return error.InvalidCommand;
    };

    // Execute command
    switch (cmd) {
        .init => try handleInit(allocator, res),
        .deploy => try handleDeploy(allocator, res),
        .test => try handleTest(allocator, res),
        .build => try handleBuild(allocator, res),
    }
}

fn printUsage() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll(
        \\Usage: buzz-cli <command> [options]
        \\
        \\Commands:
        \\  init [project-name]    Generate new project
        \\  deploy [options]       Deploy project
        \\  test                   Run project tests
        \\  build                  Build project
        \\
        \\Options:
        \\  -h, --help            Display this help and exit
        \\  -v, --version         Display version and exit
        \\  -t, --template <str>  Project template (agent/trading/yield/custom)
        \\
    );
}

fn handleInit(allocator: std.mem.Allocator, res: clap.ParseResult) !void {
    _ = allocator;
    if (res.positionals.len < 2) {
        std.debug.print("Error: Project name required\n", .{});
        return error.MissingProjectName;
    }

    const project_name = res.positionals[1];
    const template_str = res.args.template orelse "agent";
    const template = std.meta.stringToEnum(Template, template_str) orelse {
        std.debug.print("Invalid template: {s}\n", .{template_str});
        return error.InvalidTemplate;
    };

    std.debug.print("Creating new project '{s}' using template '{s}'\n", .{ project_name, @tagName(template) });
    // TODO: Implement project creation using templates
}

fn handleDeploy(allocator: std.mem.Allocator, res: clap.ParseResult) !void {
    _ = allocator;
    _ = res;
    std.debug.print("Deploying project...\n", .{});
    // TODO: Implement deployment logic
}

fn handleTest(allocator: std.mem.Allocator, res: clap.ParseResult) !void {
    _ = allocator;
    _ = res;
    std.debug.print("Running tests...\n", .{});
    // TODO: Implement test running
}

fn handleBuild(allocator: std.mem.Allocator, res: clap.ParseResult) !void {
    _ = allocator;
    _ = res;
    std.debug.print("Building project...\n", .{});
    // TODO: Implement build process
}

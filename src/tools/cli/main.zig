const std = @import("std");
const clap = @import("clap");
const idl = @import("idl.zig");

const Command = enum {
    init,
    deploy,
    test,
    build,
    idl,
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
        \\-n, --network <str>   Network to deploy to (default: devnet)
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
        .idl => try handleIDL(allocator, res),
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
        \\  idl [project-path]     Generate IDL for project
        \\
        \\Options:
        \\  -h, --help            Display this help and exit
        \\  -v, --version         Display version and exit
        \\  -t, --template <str>  Project template (agent/trading/yield/custom)
        \\  -n, --network <str>   Network to deploy to (default: devnet)
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
    if (res.positionals.len < 2) {
        std.debug.print("Error: Project path required\n", .{});
        return error.MissingProjectPath;
    }

    const project_path = res.positionals[1];
    const program_name = std.fs.path.basename(project_path);

    const options = deploy.DeployOptions{
        .project_path = project_path,
        .program_name = program_name,
        .network = res.args.network orelse "devnet",
        .version = "0.1.0",
    };

    try deploy.execute(allocator, options);
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

fn handleIDL(allocator: std.mem.Allocator, res: clap.ParseResult) !void {
    if (res.positionals.len < 2) {
        std.debug.print("Error: Project path required\n", .{});
        return error.MissingProjectPath;
    }

    const project_path = res.positionals[1];

    // Create example IDL (this will be replaced with actual program parsing)
    const example_instruction = [_]idl.InstructionArg{
        .{ .name = "amount", .type = "u64" },
    };
    const example_account = [_]idl.AccountField{
        .{ .name = "owner", .type = "pubkey" },
        .{ .name = "balance", .type = "u64" },
    };
    const example_error = [_]idl.ErrorDef{
        .{ .code = 1, .name = "InsufficientBalance", .msg = "Insufficient balance for operation" },
    };

    const idl_content = try idl.generateIDL(
        allocator,
        "example_program",
        "0.1.0",
        &[_]idl.Instruction{.{
            .name = "transfer",
            .accounts = &[_]idl.AccountMeta{
                .{ .name = "from", .isMut = true, .isSigner = true },
                .{ .name = "to", .isMut = true, .isSigner = false },
            },
            .args = &example_instruction,
        }},
        &[_]idl.Account{.{
            .name = "TokenAccount",
            .fields = &example_account,
        }},
        &example_error,
    );
    defer allocator.free(idl_content);

    // Create idl.json in project directory
    const idl_path = try std.fs.path.join(allocator, &[_][]const u8{ project_path, "idl.json" });
    defer allocator.free(idl_path);

    const file = try std.fs.createFileAbsolute(idl_path, .{});
    defer file.close();

    try file.writeAll(idl_content);

    std.debug.print("IDL generated at {s}\n", .{idl_path});
}

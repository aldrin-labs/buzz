const std = @import("std");

pub const cli = struct {
    pub const idl = @import("idl.zig");
    pub const solana = @import("solana.zig");
    pub const commands = struct {
        pub const deploy = @import("commands/deploy.zig");
    };
};

const Command = enum {
    init,
    deploy,
    run_test, // renamed from 'test' to avoid conflict with Zig keyword
    build,
    idl
};

const Template = enum {
    agent,
    trading,
    yield,
    custom,
};

const Args = struct {
    command: ?Command = null,
    help: bool = false,
    version: bool = false,
    template: ?[]const u8 = null,
    network: ?[]const u8 = null,
    positionals: std.ArrayList([]const u8),

    pub fn deinit(self: *Args) void {
        self.positionals.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try parseArgs(allocator);
    defer args.deinit();

    // Handle help and version flags
    if (args.help) {
        try printUsage();
        return;
    }

    if (args.version) {
        try std.io.getStdOut().writer().print("buzz-cli version 0.1.0\n", .{});
        return;
    }

    // Parse command and arguments
    if (args.positionals.items.len == 0) {
        try printUsage();
        return;
    }

    const cmd = args.command orelse {
        std.debug.print("Unknown command: {s}\n", .{args.positionals.items[0]});
        return error.InvalidCommand;
    };

    // Execute command
    switch (cmd) {
        .init => try handleInit(allocator, &args),
        .deploy => try handleDeploy(allocator, &args),
        .run_test => try handleTest(allocator, &args),
        .build => try handleBuild(allocator, &args),
        .idl => try handleIDL(allocator, &args),
    }
}

fn parseArgs(allocator: std.mem.Allocator) !Args {
    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();

    // Skip executable name
    _ = args_iter.skip();

    var args = Args{
        .positionals = std.ArrayList([]const u8).init(allocator),
    };

    while (args_iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            args.help = true;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            args.version = true;
        } else if (std.mem.eql(u8, arg, "-t") or std.mem.eql(u8, arg, "--template")) {
            args.template = args_iter.next() orelse return error.MissingTemplateValue;
        } else if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--network")) {
            args.network = args_iter.next() orelse return error.MissingNetworkValue;
        } else {
            try args.positionals.append(arg);
            if (args.command == null) {
                args.command = std.meta.stringToEnum(Command, arg);
            }
        }
    }

    return args;
}

fn printUsage() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll(
        \\Usage: buzz-cli <command> [options]
        \\
        \\Commands:
        \\  init [project-name]    Generate new project
        \\  deploy [options]       Deploy project
        \\  run_test               Run project tests
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

fn handleInit(allocator: std.mem.Allocator, args: *const Args) !void {
    _ = allocator;
    if (args.positionals.items.len < 2) {
        std.debug.print("Error: Project name required\n", .{});
        return error.MissingProjectName;
    }

    const project_name = args.positionals.items[1];
    const template_str = args.template orelse "agent";
    const template = std.meta.stringToEnum(Template, template_str) orelse {
        std.debug.print("Invalid template: {s}\n", .{template_str});
        return error.InvalidTemplate;
    };

    std.debug.print("Creating new project '{s}' using template '{s}'\n", .{ project_name, @tagName(template) });
    // TODO: Implement project creation using templates
}

fn handleDeploy(allocator: std.mem.Allocator, args: *const Args) !void {
    if (args.positionals.items.len < 2) {
        std.debug.print("Error: Project path required\n", .{});
        return error.MissingProjectPath;
    }

    const project_path = args.positionals.items[1];
    const program_name = std.fs.path.basename(project_path);

    const options = cli.commands.deploy.DeployOptions{
        .project_path = project_path,
        .program_name = program_name,
        .network = args.network orelse "devnet",
        .version = "0.1.0",
    };

    try cli.commands.deploy.execute(allocator, options);
}

fn handleTest(allocator: std.mem.Allocator, args: *const Args) !void {
    _ = allocator;
    _ = args;
    std.debug.print("Running tests...\n", .{});
    // TODO: Implement test running
}

fn handleBuild(allocator: std.mem.Allocator, args: *const Args) !void {
    _ = allocator;
    _ = args;
    std.debug.print("Building project...\n", .{});
    // TODO: Implement build process
}

fn handleIDL(allocator: std.mem.Allocator, args: *const Args) !void {
    if (args.positionals.items.len < 2) {
        std.debug.print("Error: Project path required\n", .{});
        return error.MissingProjectPath;
    }

    const project_path = args.positionals.items[1];

    // Create example IDL (this will be replaced with actual program parsing)
    const example_instruction = [_]cli.idl.InstructionArg{
        .{ .name = "amount", .type = "u64" },
    };
    const example_account = [_]cli.idl.AccountField{
        .{ .name = "owner", .type = "pubkey" },
        .{ .name = "balance", .type = "u64" },
    };
    const example_error = [_]cli.idl.ErrorDef{
        .{ .code = 1, .name = "InsufficientBalance", .msg = "Insufficient balance for operation" },
    };

    const program_name = std.fs.path.basename(project_path);
    const idl_content = try cli.idl.generateIDL(
        allocator,
        program_name,
        "0.1.0",
        &[_]cli.idl.Instruction{.{
            .name = "transfer",
            .accounts = &[_]cli.idl.AccountMeta{
                .{ .name = "from", .isMut = true, .isSigner = true },
                .{ .name = "to", .isMut = true, .isSigner = false },
            },
            .args = &example_instruction,
        }},
        &[_]cli.idl.Account{.{
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

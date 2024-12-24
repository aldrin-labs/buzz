const std = @import("std");
const idl = @import("../idl.zig");
const solana = @import("../solana.zig");

pub const DeployOptions = struct {
    network: []const u8 = "devnet",
    project_path: []const u8,
    program_name: []const u8,
    version: []const u8 = "0.1.0",
};

pub fn execute(allocator: std.mem.Allocator, options: DeployOptions) !void {
    std.debug.print("Deploying to {s}...\n", .{options.network});

    // Generate IDL for the project
    std.debug.print("Generating IDL...\n", .{});
    const idl_content = try generateProjectIDL(allocator, options);
    defer allocator.free(idl_content);

    // Write IDL to file
    const idl_path = try std.fs.path.join(allocator, &[_][]const u8{ options.project_path, "idl.json" });
    defer allocator.free(idl_path);

    const file = try std.fs.createFileAbsolute(idl_path, .{});
    defer file.close();
    try file.writeAll(idl_content);

    std.debug.print("IDL generated at {s}\n", .{idl_path});

    // Perform deployment using IDL
    try performDeployment(allocator, idl_content, options);
}

fn generateProjectIDL(allocator: std.mem.Allocator, options: DeployOptions) ![]const u8 {
    // Parse project files to extract program interface
    // For now, using example IDL structure
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

    return idl.generateIDL(
        allocator,
        options.program_name,
        options.version,
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
}

fn performDeployment(allocator: std.mem.Allocator, idl_content: []const u8, options: DeployOptions) !void {
    var client = solana.SolanaClient.init(allocator, options.network);
    defer client.deinit();

    // Build project
    std.debug.print("Building project...\n", .{});
    const program_path = try std.fs.path.join(allocator, &[_][]const u8{ options.project_path, "target", "deploy" });
    defer allocator.free(program_path);

    // Deploy program and get program ID
    std.debug.print("Deploying to {s}...\n", .{options.network});
    const program_id = try client.deployProgram(program_path, idl_content);
    defer allocator.free(program_id);

    // Verify deployment
    std.debug.print("Verifying deployment...\n", .{});
    try client.verifyDeployment(program_id);

    std.debug.print("Successfully deployed program {s} to {s}\n", .{ program_id, options.network });
}

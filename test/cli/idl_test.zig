const std = @import("std");
const testing = std.testing;
const idl = @import("../../src/tools/cli/idl.zig");
const solana = @import("../../src/tools/cli/solana.zig");
const deploy = @import("../../src/tools/cli/commands/deploy.zig");

test "IDL instruction parsing" {
    const allocator = testing.allocator;
    
    const instruction_json =
        \\{
        \\  "name": "transfer",
        \\  "accounts": [
        \\    {"name": "from", "isMut": true, "isSigner": true},
        \\    {"name": "to", "isMut": true, "isSigner": false}
        \\  ],
        \\  "args": [
        \\    {"name": "amount", "type": "u64"}
        \\  ]
        \\}
    ;
    
    const parsed = try idl.parseInstruction(allocator, instruction_json);
    defer parsed.deinit();
    
    try testing.expectEqualStrings("transfer", parsed.name);
    try testing.expectEqual(@as(usize, 2), parsed.accounts.len);
    try testing.expectEqual(@as(usize, 1), parsed.args.len);
}

test "IDL generation basic test" {
    const allocator = testing.allocator;
    
    const generated = try idl.generateIDL(
        allocator,
        "test_program",
        "0.1.0",
        &[_]idl.Instruction{.{
            .name = "initialize",
            .accounts = &[_]idl.AccountMeta{
                .{ .name = "owner", .isMut = true, .isSigner = true },
            },
            .args = &[_]idl.InstructionArg{
                .{ .name = "amount", .type = "u64" },
            },
        }},
        &[_]idl.Account{.{
            .name = "State",
            .fields = &[_]idl.AccountField{
                .{ .name = "owner", .type = "pubkey" },
                .{ .name = "balance", .type = "u64" },
            },
        }},
        &[_]idl.ErrorDef{
            .{ .code = 1, .name = "InvalidAmount", .msg = "Amount must be greater than 0" },
        },
    );
    defer allocator.free(generated);

    // Parse generated IDL to verify contents
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, generated, .{});
    defer parsed.deinit();

    try testing.expectEqualStrings("test_program", parsed.value.object.get("name").?.string);
    try testing.expectEqualStrings("0.1.0", parsed.value.object.get("version").?.string);
}

test "Solana client deployment error handling" {
    const allocator = testing.allocator;
    var client = solana.SolanaClient.init(allocator, "devnet");
    defer client.deinit();
    
    // Test invalid program path
    const result = client.deployProgram("/nonexistent/path", "{}");
    try testing.expectError(error.DeploymentFailed, result);
}

test "Solana client network endpoints" {
    const allocator = testing.allocator;
    var client = solana.SolanaClient.init(allocator, "devnet");
    defer client.deinit();

    try testing.expectEqualStrings("https://api.devnet.solana.com", client.getEndpoint());

    client = solana.SolanaClient.init(allocator, "mainnet-beta");
    try testing.expectEqualStrings("https://api.mainnet-beta.solana.com", client.getEndpoint());

    client = solana.SolanaClient.init(allocator, "testnet");
    try testing.expectEqualStrings("https://api.testnet.solana.com", client.getEndpoint());

    client = solana.SolanaClient.init(allocator, "http://localhost:8899");
    try testing.expectEqualStrings("http://localhost:8899", client.getEndpoint());
}

test "Template generation" {
    const allocator = testing.allocator;
    const template_vars = .{
        .project_name = "test_bot",
        .description = "Test bot description",
        .strategy_name = "test_strategy",
        .version = "0.1.0",
    };
    
    const generated = try deploy.generateFromTemplate(
        allocator,
        "trading",
        template_vars
    );
    defer allocator.free(generated);
    
    try testing.expect(std.mem.indexOf(u8, generated, "test_bot") != null);
    try testing.expect(std.mem.indexOf(u8, generated, "test_strategy") != null);
}

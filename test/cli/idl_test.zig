const std = @import("std");
const testing = std.testing;
const json = std.json;
const idl = @import("tools").cli.idl;
const solana = @import("tools").cli.solana;
const deploy = @import("tools").cli.commands.deploy;

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

test "IDL generation includes program name and version" {
    const allocator = testing.allocator;
    
    const program_name = "test_program";
    const version = "0.1.0";
    
    const generated = try idl.generateIDL(
        allocator,
        program_name,
        version,
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
    const parsed = try json.parseFromSlice(json.Value, allocator, generated, .{});
    defer parsed.deinit();

    // Verify program name and version
    try testing.expectEqualStrings(program_name, parsed.value.object.get("name").?.string);
    try testing.expectEqualStrings(version, parsed.value.object.get("version").?.string);
    
    // Verify required IDL fields exist
    try testing.expect(parsed.value.object.get("instructions") != null);
    try testing.expect(parsed.value.object.get("accounts") != null);
    try testing.expect(parsed.value.object.get("errors") != null);
    
    // Verify instruction structure
    const instructions = parsed.value.object.get("instructions").?.array;
    try testing.expectEqual(@as(usize, 1), instructions.items.len);
    try testing.expectEqualStrings("initialize", instructions.items[0].object.get("name").?.string);
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

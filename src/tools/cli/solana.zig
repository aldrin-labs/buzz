const std = @import("std");
const json = std.json;

pub const SolanaClient = struct {
    network: []const u8,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, network: []const u8) Self {
        return Self{
            .allocator = allocator,
            .network = network,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn getEndpoint(self: *const Self) []const u8 {
        if (std.mem.eql(u8, self.network, "mainnet-beta")) {
            return "https://api.mainnet-beta.solana.com";
        } else if (std.mem.eql(u8, self.network, "devnet")) {
            return "https://api.devnet.solana.com";
        } else if (std.mem.eql(u8, self.network, "testnet")) {
            return "https://api.testnet.solana.com";
        } else {
            return self.network; // Assume custom RPC endpoint
        }
    }

    pub fn deployProgram(self: *Self, program_path: []const u8, idl: []const u8) ![]const u8 {
        const parsed = try json.parseFromSlice(json.Value, self.allocator, idl, .{});
        defer parsed.deinit();

        // Extract program ID from IDL if available
        const program_id = if (parsed.value.object.get("programId")) |id| id.string else return error.MissingProgramId;

        // Configure Solana CLI
        const config_args = try std.fmt.allocPrint(
            self.allocator,
            "solana config set --url {s}",
            .{self.getEndpoint()}
        );
        defer self.allocator.free(config_args);

        var config_child = std.process.Child.init(&.{ "sh", "-c", config_args }, self.allocator);
        _ = try config_child.spawnAndWait();

        // Deploy program using Solana CLI
        const deploy_args = try std.fmt.allocPrint(
            self.allocator,
            "solana program deploy {s} --program-id {s}",
            .{ program_path, program_id }
        );
        defer self.allocator.free(deploy_args);

        var deploy_child = std.process.Child.init(&.{ "sh", "-c", deploy_args }, self.allocator);
        const deploy_result = try deploy_child.spawnAndWait();

        if (deploy_result.Exited != 0) {
            return error.DeploymentFailed;
        }

        return program_id;
    }

    pub fn verifyDeployment(self: *Self, program_id: []const u8) !void {
        const verify_args = try std.fmt.allocPrint(
            self.allocator,
            "solana program show {s}",
            .{program_id}
        );
        defer self.allocator.free(verify_args);

        var verify_child = std.process.Child.init(&.{ "sh", "-c", verify_args }, self.allocator);
        const verify_result = try verify_child.spawnAndWait();

        if (verify_result.Exited != 0) {
            return error.VerificationFailed;
        }

        std.debug.print("Program {s} successfully verified on {s}\n", .{ program_id, self.network });
    }
};

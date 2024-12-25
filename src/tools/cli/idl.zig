const std = @import("std");

pub const IDLError = error{
    InvalidProgramName,
    InvalidVersion,
    OutOfMemory,
    InvalidInstruction,
    InvalidAccount,
    SerializationError,
};

pub const AccountMeta = struct {
    name: []const u8,
    isMut: bool,
    isSigner: bool,
};

pub const InstructionArg = struct {
    name: []const u8,
    type: []const u8,
};

pub const Instruction = struct {
    name: []const u8,
    accounts: []const AccountMeta,
    args: []const InstructionArg,
};

pub const AccountField = struct {
    name: []const u8,
    type: []const u8,
};

pub const Account = struct {
    name: []const u8,
    fields: []const AccountField,
};

pub const ErrorDef = struct {
    code: u32,
    name: []const u8,
    msg: []const u8,
};

pub const IDL = struct {
    version: []const u8,
    name: []const u8,
    instructions: []const Instruction,
    accounts: []const Account,
    errors: []const ErrorDef,

    pub fn toJSON(self: *const IDL, allocator: std.mem.Allocator) ![]u8 {
        var json = std.ArrayList(u8).init(allocator);
        errdefer json.deinit();

        try json.appendSlice("{\n");
        try json.appendSlice("  \"version\": \"");
        try json.appendSlice(self.version);
        try json.appendSlice("\",\n");
        try json.appendSlice("  \"name\": \"");
        try json.appendSlice(self.name);
        try json.appendSlice("\",\n");

        // Instructions
        try json.appendSlice("  \"instructions\": [\n");
        for (self.instructions, 0..) |inst, i| {
            try json.appendSlice("    {\n");
            try json.appendSlice("      \"name\": \"");
            try json.appendSlice(inst.name);
            try json.appendSlice("\",\n");
            
            // Accounts
            try json.appendSlice("      \"accounts\": [\n");
            for (inst.accounts, 0..) |acc, j| {
                try json.appendSlice("        {\n");
                try json.appendSlice("          \"name\": \"");
                try json.appendSlice(acc.name);
                try json.appendSlice("\",\n");
                try json.appendSlice("          \"isMut\": ");
                try json.appendSlice(if (acc.isMut) "true" else "false");
                try json.appendSlice(",\n");
                try json.appendSlice("          \"isSigner\": ");
                try json.appendSlice(if (acc.isSigner) "true" else "false");
                try json.appendSlice("\n");
                try json.appendSlice("        }");
                if (j < inst.accounts.len - 1) try json.appendSlice(",");
                try json.appendSlice("\n");
            }
            try json.appendSlice("      ],\n");

            // Args
            try json.appendSlice("      \"args\": [\n");
            for (inst.args, 0..) |arg, j| {
                try json.appendSlice("        {\n");
                try json.appendSlice("          \"name\": \"");
                try json.appendSlice(arg.name);
                try json.appendSlice("\",\n");
                try json.appendSlice("          \"type\": \"");
                try json.appendSlice(arg.type);
                try json.appendSlice("\"\n");
                try json.appendSlice("        }");
                if (j < inst.args.len - 1) try json.appendSlice(",");
                try json.appendSlice("\n");
            }
            try json.appendSlice("      ]\n");
            try json.appendSlice("    }");
            if (i < self.instructions.len - 1) try json.appendSlice(",");
            try json.appendSlice("\n");
        }
        try json.appendSlice("  ],\n");

        // Accounts
        try json.appendSlice("  \"accounts\": [\n");
        for (self.accounts, 0..) |acc, i| {
            try json.appendSlice("    {\n");
            try json.appendSlice("      \"name\": \"");
            try json.appendSlice(acc.name);
            try json.appendSlice("\",\n");
            try json.appendSlice("      \"type\": {\n");
            try json.appendSlice("        \"kind\": \"struct\",\n");
            try json.appendSlice("        \"fields\": [\n");
            for (acc.fields, 0..) |field, j| {
                try json.appendSlice("          {\n");
                try json.appendSlice("            \"name\": \"");
                try json.appendSlice(field.name);
                try json.appendSlice("\",\n");
                try json.appendSlice("            \"type\": \"");
                try json.appendSlice(field.type);
                try json.appendSlice("\"\n");
                try json.appendSlice("          }");
                if (j < acc.fields.len - 1) try json.appendSlice(",");
                try json.appendSlice("\n");
            }
            try json.appendSlice("        ]\n");
            try json.appendSlice("      }\n");
            try json.appendSlice("    }");
            if (i < self.accounts.len - 1) try json.appendSlice(",");
            try json.appendSlice("\n");
        }
        try json.appendSlice("  ],\n");

        // Errors
        try json.appendSlice("  \"errors\": [\n");
        for (self.errors, 0..) |err, i| {
            try json.appendSlice("    {\n");
            try json.appendSlice("      \"code\": ");
            var code_buf: [10]u8 = undefined;
            const code_str = try std.fmt.bufPrint(&code_buf, "{d}", .{err.code});
            try json.appendSlice(code_str);
            try json.appendSlice(",\n");
            try json.appendSlice("      \"name\": \"");
            try json.appendSlice(err.name);
            try json.appendSlice("\",\n");
            try json.appendSlice("      \"msg\": \"");
            try json.appendSlice(err.msg);
            try json.appendSlice("\"\n");
            try json.appendSlice("    }");
            if (i < self.errors.len - 1) try json.appendSlice(",");
            try json.appendSlice("\n");
        }
        try json.appendSlice("  ]\n");
        try json.appendSlice("}\n");

        return json.toOwnedSlice();
    }
};

pub fn generateIDL(
    allocator: std.mem.Allocator,
    program_name: []const u8,
    version: []const u8,
    instructions: []const Instruction,
    accounts: []const Account,
    errors: []const ErrorDef,
) ![]u8 {
    const idl = IDL{
        .version = version,
        .name = program_name,
        .instructions = instructions,
        .accounts = accounts,
        .errors = errors,
    };

    return try idl.toJSON(allocator);
}

// Helper function to create an instruction
pub fn createInstruction(
    name: []const u8,
    accounts: []const AccountMeta,
    args: []const InstructionArg,
) Instruction {
    return Instruction{
        .name = name,
        .accounts = accounts,
        .args = args,
    };
}

// Helper function to create an account
pub fn createAccount(
    name: []const u8,
    fields: []const AccountField,
) Account {
    return Account{
        .name = name,
        .fields = fields,
    };
}

// Helper function to create an error definition
pub fn createError(
    code: u32,
    name: []const u8,
    msg: []const u8,
) ErrorDef {
    return ErrorDef{
        .code = code,
        .name = name,
        .msg = msg,
    };
}

pub const ParsedInstruction = struct {
    name: []const u8,
    accounts: []AccountMeta,
    args: []InstructionArg,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *ParsedInstruction) void {
        for (self.accounts) |acc| {
            self.allocator.free(acc.name);
        }
        for (self.args) |arg| {
            self.allocator.free(arg.name);
            self.allocator.free(arg.type);
        }
        self.allocator.free(self.name);
        self.allocator.free(self.accounts);
        self.allocator.free(self.args);
    }
};

pub fn parseInstruction(allocator: std.mem.Allocator, instruction_json: []const u8) !ParsedInstruction {
    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, instruction_json, .{});
    defer parsed.deinit();

    const root = parsed.value.object;
    
    // Parse name
    const name = try allocator.dupe(u8, root.get("name").?.string);
    errdefer allocator.free(name);

    // Parse accounts
    const accounts_array = root.get("accounts").?.array;
    var accounts = try allocator.alloc(AccountMeta, accounts_array.items.len);
    errdefer {
        for (accounts) |acc| {
            allocator.free(acc.name);
        }
        allocator.free(accounts);
    }

    for (accounts_array.items, 0..) |acc, i| {
        const acc_obj = acc.object;
        accounts[i] = .{
            .name = try allocator.dupe(u8, acc_obj.get("name").?.string),
            .isMut = acc_obj.get("isMut").?.bool,
            .isSigner = acc_obj.get("isSigner").?.bool,
        };
    }

    // Parse args
    const args_array = root.get("args").?.array;
    var args = try allocator.alloc(InstructionArg, args_array.items.len);
    errdefer {
        for (args) |arg| {
            allocator.free(arg.name);
            allocator.free(arg.type);
        }
        allocator.free(args);
    }

    for (args_array.items, 0..) |arg, i| {
        const arg_obj = arg.object;
        args[i] = .{
            .name = try allocator.dupe(u8, arg_obj.get("name").?.string),
            .type = try allocator.dupe(u8, arg_obj.get("type").?.string),
        };
    }

    return ParsedInstruction{
        .name = name,
        .accounts = accounts,
        .args = args,
        .allocator = allocator,
    };
}

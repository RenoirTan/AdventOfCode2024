const std = @import("std");
const parseInt = std.fmt.parseInt;

pub const VariableDeclaration = struct {
    variable: usize,
    value: u1,
};

pub const Operation = enum { AND, OR, XOR };
pub const OperationDeclaration = struct {
    a: usize,
    b: usize,
    c: usize,
    operation: Operation,
};

pub const Grove = struct {
    allocator: std.mem.Allocator,
    indices: std.StringHashMap(usize),
    variables: std.ArrayList([]const u8),
    var_decls: std.ArrayList(VariableDeclaration),
    opr_decls: std.ArrayList(OperationDeclaration),

    pub fn init(allocator: std.mem.Allocator) Grove {
        const indices = std.StringHashMap(usize).init(allocator);
        const variables = std.ArrayList([]const u8).init(allocator);
        const var_decls = std.ArrayList(VariableDeclaration).init(allocator);
        const opr_decls = std.ArrayList(OperationDeclaration).init(allocator);
        return Grove{
            .allocator = allocator,
            .indices = indices,
            .variables = variables,
            .var_decls = var_decls,
            .opr_decls = opr_decls,
        };
    }

    pub fn deinit(self: *Grove) void {
        self.indices.deinit();
        self.variables.deinit();
        self.var_decls.deinit();
        self.opr_decls.deinit();
    }

    fn insertVar(self: *Grove, variable: []const u8) !usize {
        // std.debug.print("Variable: {s}\n", .{variable});
        const alloc_var = try self.allocator.alloc(u8, 3);
        @memcpy(alloc_var, variable);
        const vars = self.variables.items.len;
        try self.variables.append(alloc_var);
        try self.indices.put(alloc_var, vars);
        return vars;
    }

    pub fn getVarIndex(self: *Grove, variable: []const u8) !usize {
        if (self.indices.contains(variable)) {
            return self.indices.get(variable) orelse unreachable;
        } else {
            return self.insertVar(variable);
        }
    }

    pub fn parseInstruction(self: *Grove, s: []const u8) !*Grove {
        // std.debug.print("Instruction: {s}\n", .{s});
        if (s.len == 6 and s[3] == ':') {
            return self.parseVarDecl(s);
        } else if (s.len >= 17 and (s[12] == '>' or s[13] == '>')) {
            return self.parseOprDecl(s);
        } else return self;
    }

    fn parseVarDecl(self: *Grove, s: []const u8) !*Grove {
        const name = s[0..3];
        const value: u1 = switch (s[5]) {
            '0' => 0,
            '1' => 1,
            else => return error.Bruh,
        };
        const variable = try self.getVarIndex(name);
        const var_decl = VariableDeclaration{
            .variable = variable,
            .value = value,
        };
        try self.var_decls.append(var_decl);
        return self;
    }

    fn parseOprDecl(self: *Grove, s: []const u8) !*Grove {
        const stuff = if (s[12] == '>') high: {
            const op = Operation.OR;
            const an = s[0..3];
            const bn = s[7..10];
            const cn = s[14..17];
            break :high .{ an, bn, cn, op };
        } else high: {
            const op = if (s[4] == 'A') low: {
                break :low Operation.AND;
            } else low: {
                break :low Operation.XOR;
            };
            const an = s[0..3];
            const bn = s[8..11];
            const cn = s[15..18];
            break :high .{ an, bn, cn, op };
        };
        const a = try self.getVarIndex(stuff[0]);
        const b = try self.getVarIndex(stuff[1]);
        const c = try self.getVarIndex(stuff[2]);
        const operation = stuff[3];
        const opr_decl = OperationDeclaration{
            .a = a,
            .b = b,
            .c = c,
            .operation = operation,
        };
        try self.opr_decls.append(opr_decl);
        return self;
    }

    pub fn solve(self: *Grove, allocator: std.mem.Allocator) !std.StringHashMap(u1) {
        const n_eqn = self.opr_decls.items.len;
        const n_var = self.variables.items.len;
        // std.debug.print("n_eqn {d} n_var {d}\n", .{ n_eqn, n_var });
        var vars = std.ArrayList(i8).init(self.allocator); // [n_var]?u1{null};
        defer vars.deinit();
        for (0..n_var) |_| {
            try vars.append(-1);
        }
        for (self.var_decls.items) |var_decl| {
            const code = var_decl.variable;
            const val = var_decl.value;
            vars.items[code] = val;
        }

        var ok = false;
        while (!ok) {
            ok = true;
            for (0..n_eqn) |index| {
                const eqn = self.opr_decls.items[index];
                if (vars.items[eqn.c] != -1) {
                    continue;
                }
                ok = false;
                const a = vars.items[eqn.a];
                const b = vars.items[eqn.b];
                const c_ref = &vars.items[eqn.c];
                if (a != -1 and b != -1) {
                    c_ref.* = switch (eqn.operation) {
                        Operation.AND => a & b,
                        Operation.XOR => a ^ b,
                        Operation.OR => a | b,
                    };
                }
            }
        }
        var vars_str = std.StringHashMap(u1).init(allocator);
        for (0..n_var) |v| {
            const name = self.variables.items[v];
            const value: u1 = switch (vars.items[v]) {
                0 => 0,
                1 => 1,
                else => 0,
            };
            try vars_str.put(name, value);
        }
        return vars_str;
    }

    pub fn getXY(self: *Grove) !struct { u64, u64 } {
        var x: u64 = 0;
        var y: u64 = 0;
        for (self.var_decls.items) |var_decl| {
            const i = var_decl.variable;
            const key = self.variables.items[i];
            if (key[0] != 'x' and key[0] != 'y') {
                continue;
            }
            const shifted = try std.fmt.parseInt(u6, key[1..3], 10);
            const value = @as(u64, var_decl.value);
            if (key[0] == 'x') {
                x |= value << shifted;
            } else {
                y |= value << shifted;
            }
        }
        return .{ x, y };
    }

    fn findOperationFromLhs(
        self: *Grove,
        a: usize,
        b: usize,
        op: Operation,
    ) ?OperationDeclaration {
        for (self.opr_decls.items) |opr_decl| {
            if (((opr_decl.a == a and opr_decl.b == b) or (opr_decl.a == b and opr_decl.b == a)) and opr_decl.operation == op) {
                return opr_decl;
            }
        }
        return null;
    }

    fn findOperationFromRhs(self: *Grove, c: usize) ?OperationDeclaration {
        for (self.opr_decls.items) |opr_decl| {
            if (opr_decl.c == c) {
                return opr_decl;
            }
        }
        return null;
    }

    // the assumption is that swaps only happen within the adders for each bit
    // not across adders for multiple bits
    pub fn searchForDerailments(
        self: *Grove,
        allocator: std.mem.Allocator,
    ) !std.ArrayList(usize) {
        var bad = std.ArrayList(usize).init(allocator);

        var x = self.indices.get("x00") orelse return error.Bruh;
        var y = self.indices.get("y00") orelse return error.Bruh;
        var z = self.indices.get("z00") orelse return error.Bruh;
        var c = self.findOperationFromLhs(x, y, Operation.AND).?.c;
        var h: usize = 0;
        var b: usize = 0;
        var d: usize = 0;

        var xn = "x00";
        var yn = "y00";
        var zn = "z00";

        for (1..100) |i| {
            const c1 = i / 10;
            const c2 = i % 10;
            xn[1] = c1;
            xn[2] = c2;
            yn[1] = c1;
            yn[2] = c2;
            zn[1] = c1;
            zn[2] = c2;
            x = self.indices.get(xn) orelse break;
            y = self.indices.get(yn) orelse break;
            z = self.indices.get(zn) orelse break;

            const x_xor_y = self.findOperationFromLhs(x, y, Operation.XOR) orelse break;
            h = x_xor_y.c;
            const x_and_y = self.findOperationFromLhs(x, y, Operation.AND) orelse break;
            b = x_and_y.c;
            const c_and_h = self.findOperationFromLhs(c, h, Operation.AND);
            if (c_and_h == null) {
                try bad.append(h);
                try bad.append(b);
                std.mem.swap(usize, &h, &b);
                continue;
            }
            d = c_and_h.c;

            const b_or_d = self.findOperationFromLhs(b, d, Operation.OR) orelse break;
            const c_xor_h = self.findOperationFromLhs(c, h, Operation.XOR);
            if (b_or_d.c == z) {
                try bad.append(z);
                try bad.append(c_xor_h.c);
                c = c_xor_h.c;
            } else {
                c = b_or_d.c;
            }
        }

        return bad;
    }
};

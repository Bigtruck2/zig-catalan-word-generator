const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const Hashmap = std.AutoHashMap;
const debug = std.debug;
const BadInput = error{ NumberIsOdd, OutOfRange };
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
pub fn getNum() !usize {
    const stdin = std.io.getStdIn().reader();
    var buf: [10]u8 = undefined;
    debug.print("Enter a number: ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |num_input| {
        if (@mod(try std.fmt.parseInt(usize, num_input, 10), 2) == 1) {
            return BadInput.NumberIsOdd;
        }
        return std.fmt.parseInt(usize, num_input, 10);
    } else {
        return @as(usize, 22);
    }
}
pub fn contains(list: anytype, key: anytype) bool {
    for (list) |value| {
        if (value == key) {
            return true;
        }
    }
    return false;
}
pub fn firstOccurance(list: anytype, key: anytype) BadInput!usize {
    for (list, 0..) |value, i| {
        if (value == key) {
            return i;
        }
    }
    return BadInput.OutOfRange;
}
pub fn keyGen(length: usize, list_ptr: *std.ArrayList(u8)) !void {
    const rand = std.crypto.random;
    const half_len = @divExact(length, 2);
    var zero_list = ArrayList(usize).init(allocator);
    var zero_positions = Hashmap(usize, usize).init(allocator);
    //defer list.deinit();
    defer zero_positions.deinit();
    defer zero_list.deinit();
    for (1..half_len) |i| {
        try zero_list.append(i);
    }
    var valid_spot: usize = 0;
    for (0..half_len - 1) |_| {
        const index = blk: {
            while (true) {
                const num: usize = rand.intRangeAtMost(usize, valid_spot, zero_list.items.len);
                if (!contains(zero_list.items[num..], 0)) {
                    break :blk num;
                } else {
                    valid_spot = try firstOccurance(zero_list.items[num..], 0);
                }
            }
        };
        for (index..half_len - 1) |i| {
            zero_list.items[i] -= if (zero_list.items[i] != 0) 1 else 0;
        }
        if (zero_positions.get(index)) |value| {
            try zero_positions.put(index, value + 1);
        } else {
            try zero_positions.put(index, 1);
        }
    }
    for (0..half_len) |i| {
        try list_ptr.*.append('1');
        if (zero_positions.get(i)) |value| {
            try list_ptr.*.appendNTimes('0', value);
        }
    }
    try list_ptr.*.append('0');
}
pub fn getBalance(range: []u8) bool {
    var position: isize = 0;
    for (range) |value| {
        if (value == '1') {
            position += 1;
        } else {
            position -= 1;
        }
        if (position < 0) {
            return false;
        }
    }
    return true;
}
pub fn main() !void {
    var argsIterator = try std.process.ArgIterator.initWithAllocator(allocator);
    defer argsIterator.deinit();
    var run: bool = true;
    _ = argsIterator.next();
    while (run) {
        var length: usize = 0;
        if(argsIterator.next()) |len| {
            length = try std.fmt.parseInt(usize,len,10);
            run = false;
        }else{
            length = try getNum();
        }
        var value = ArrayList(u8).init(allocator);
        defer value.deinit();
        try keyGen(length,&value);
        debug.print("{s}\n", .{value.items});
    }
}
test "test dyck word" {
    const rand = std.crypto.random;
    for (0..100) |_| {
        var value = ArrayList(u8).init(allocator);
        defer value.deinit();
        try keyGen(rand.intRangeAtMost(usize, 2, 100)*2,&value);
        try expect(getBalance(value.items));
    }
}

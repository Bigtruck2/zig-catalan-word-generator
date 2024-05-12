const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const Hashmap = std.AutoHashMap;
const stdout = std.io.getStdOut().writer();
const OddNumberError = error {
    NumberIsOdd
};
pub fn getNum() !usize{
    const stdin = std.io.getStdIn().reader();
    var buf: [10]u8 = undefined;
    try stdout.print("Enter a number: ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..],'\n')) |num_input| {
        if(@mod(try std.fmt.parseInt(usize,num_input,10),2)==1){
            return OddNumberError.NumberIsOdd;
        }
        return std.fmt.parseInt(usize, num_input,10);
    }else{
        return @as(usize,22);        
    }
}
pub fn contains(list: anytype, key:anytype) bool{
    for (list) |value| {
        if(value==key){
            return true;
        }
    }
    return false;
}
pub fn firstOccurance(list:anytype, key:anytype) usize{
    for (list, 0..) |value, i| {
        if(value==key){
            return i;
        }
    }
    return undefined;
}
pub fn keyGen(length: usize) ![]u8{
    const rand = std.crypto.random;
    const half_len = @divExact(length,2);
    const allocator = std.heap.page_allocator;
    var list = ArrayList(u8).init(allocator);
    var zero_list = ArrayList(u64).init(allocator);
    var zero_positions = Hashmap(usize,usize).init(allocator);
    errdefer list.deinit();
    defer zero_positions.deinit();
    defer zero_list.deinit();
    for (1..half_len) |i| {
        try zero_list.append(i);
    }
    var valid_spot: usize = 0;
    for (0..half_len-1) |_| {
        const index = blk:{
            while(true){
                const num: u64 = rand.intRangeAtMost(u64,valid_spot,@as(u64,zero_list.items.len-1));
                if(!contains(zero_list.items[num..],0)){
                    break :blk num;
                }else {
                    valid_spot = firstOccurance(zero_list.items[num..],0);
                }
            }
        };
        for (index..half_len-1) |i| {
            zero_list.items[i]-= if(zero_list.items[i]!=0) 1 else 0;
        }
        if(zero_positions.get(index+1))|value|{
            try zero_positions.put(index+1,value+1);
        }else {
            try zero_positions.put(index+1,1);
        }
    }
    for (0..half_len) |i| {
        try list.append('1');
        if(zero_positions.get(i))|value|{
            try list.appendNTimes('0',value);
        }
    }
    try list.append('0');
    return list.items; 
}
pub fn getBalance(range: []u8) bool {
  var position: i64 = 0;
    for (range) |value| {
        if(value == '1'){
            position+=1;
       }else {
            position-=1;
       }
       if(position<0){
            return false;
       }
    }
    return true;
}
pub fn main() !void {
    const value = try keyGen(try getNum());
    try stdout.print("{s}\n",.{value}); 
}
test "test dyck word"{
    try expect(getBalance(try keyGen(24)));
}

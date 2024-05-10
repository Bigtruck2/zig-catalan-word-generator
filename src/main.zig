const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const SegmentedList = std.segmentedList;
const stdout = std.io.getStdOut().writer();
const OddNumberError = error {
    NumberIsOdd
};
pub fn getNum() !usize{
    const stdin = std.io.getStdIn().reader();
    var buf: [10]u8 = undefined;
    try stdout.print("enter a number: ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..],'\n')) |num_input| {
        if(@mod(try std.fmt.parseInt(usize,num_input,10),2)==1){
            return OddNumberError.NumberIsOdd;
        }
        return std.fmt.parseInt(usize, num_input,10);
    }else{
        return @as(usize,22);        
    }
}
pub fn getFirstOccurance(list: anytype, key:anytype) !usize{
    for (list, 0..) |value, i| {
        std.log.debug("{any}{any}{any}", .{value,@as(u8,key),value==key});
        if(value==key){
        
            std.log.debug("reached {any}", .{i});
            return i;
        }
    }
    return OddNumberError.NumberIsOdd;
}
pub fn keyGen(length: usize) ![]u8{
    const rand = std.crypto.random;
    const half_len = @divExact(length,2);
    const allocator = std.heap.page_allocator;
    var list = ArrayList(u8).init(allocator);
    var zero_list = ArrayList(u64).init(allocator);
    var zero_positions = ArrayList(u64).init(allocator);
    errdefer list.deinit();
    defer zero_positions.deinit();
    defer zero_list.deinit();
    try list.appendNTimes('1',half_len); 
    for (1..half_len) |i| {
        try zero_list.append(i);
    }
    std.log.debug("{}", .{zero_list});
    for (0..half_len) |_| {
        const index = blk:{
            while(true){
                const num: u64 = rand.intRangeAtMost(u64,0,@as(u64,zero_list.items.len-1));
                if(zero_list.items[num]>0){
                    break :blk num;
                }
            }
        };
        for (index..zero_list.items.len-index-1) |i| {
            zero_list.items[i]-=1;
        }
        try zero_positions.insert(index+1,'0');
    }
    //for (0..half_len-1)|_| {
    //    while (true) {
    //        const rand = std.crypto.random;
   //        const index = rand.intRangeAtMost(u64,1,@as(u64,list.items.len-1));
    //        const occurance = try getFirstOccurance(list.items[index..],'1');
    //        std.log.debug("{any}{any}", .{index+occurance,list.items[0..occurance+index-1]});
     //       if(getBalance(list.items[0..occurance+index-1])>1){
     //           try list.insert(occurance+index,'0');
     //           std.log.debug("{any}", .{list.items});
     //           break;
     //       }
     //   }
    //}
    //try list.append('0');
    return list.items; 
}
pub fn getBalance(range: []u8) i64 {
  var position: i64 = 0;
    for (range) |value| {
        if(value == '1'){
            position+=1;
       }else {
            position-=1;
       }
       if(position<0){
            return position;
       }
    }
    return position;
}
pub fn main() !void {
    const value = try keyGen(try getNum());
    try stdout.print("{s}\n",.{value}); 
}
test "test dyck word"{
    try expect(getBalance(try keyGen(24))!=0);
}

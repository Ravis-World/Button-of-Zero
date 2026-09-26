pub const Logic = struct {
    values: [4]i32,

    pub fn init(values: [4]i32) Logic {
        return .{
            .values = values,
        };
    }

    pub fn changeValue(self: *Logic, index: usize, amount: i32) void {
        if (index >= self.values.len) {
            return;
        }

        self.values[index] += amount;
    }

    pub fn isSolved(self: Logic) bool {
        for (self.values) |value| {
            if (value != 0) {
                return false;
            }
        }

        return true;
    }
};
pub const Counter = struct {
    value: i32,

    pub fn init(value: i32) Counter {
        return .{
            .value = value,
        };
    }

    pub fn increment(self: *Counter) void {
        self.value += 1;
    }

    pub fn decrement(self: *Counter) void {
        if (self.value > 0) {
            self.value -= 1;
        }
    }

    pub fn isSolved(self: Counter) bool {
        return self.value == 0;
    }
};
pub const NumberBox = struct {
    value: i32,

    pub fn init(value: i32) NumberBox {
        return .{
            .value = value,
        };
    }

    pub fn setValue(self: *NumberBox, value: i32) void {
        self.value = value;
    }

    pub fn isSolved(self: NumberBox) bool {
        return self.value == 0;
    }
};
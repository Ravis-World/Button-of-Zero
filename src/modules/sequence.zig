pub const Sequence = struct {
    values: [5]i32,
    selected: usize,

    pub fn init(values: [5]i32) Sequence {
        return .{
            .values = values,
            .selected = 0,
        };
    }

    pub fn changeValue(self: *Sequence, amount: i32) void {
        const index = self.selected;

        self.values[index] += amount;
    }

    pub fn select(self: *Sequence, index: usize) void {
        if (index < self.values.len) {
            self.selected = index;
        }
    }

    pub fn isSolved(self: Sequence) bool {
        for (self.values) |value| {
            if (value != 0) {
                return false;
            }
        }

        return true;
    }
};
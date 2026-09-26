pub const Dropdown = struct {
    selected: i32,
    option_count: i32,

    pub fn init(option_count: i32, selected: i32) Dropdown {
        return .{
            .selected = selected,
            .option_count = option_count,
        };
    }

    pub fn select(self: *Dropdown, value: i32) void {
        if (value >= 0 and value < self.option_count) {
            self.selected = value;
        }
    }

    pub fn isSolved(self: Dropdown) bool {
        return self.selected == 0;
    }
};
pub const Toggle = struct {
    enabled: bool,

    pub fn init(enabled: bool) Toggle {
        return .{
            .enabled = enabled,
        };
    }

    pub fn toggle(self: *Toggle) void {
        self.enabled = !self.enabled;
    }

    pub fn value(self: Toggle) i32 {
        if (self.enabled) {
            return 1;
        }

        return 0;
    }

    pub fn isSolved(self: Toggle) bool {
        return !self.enabled;
    }
};
pub const Knob = struct {
    value: i32,
    minimum: i32,
    maximum: i32,

    pub fn init(value: i32, minimum: i32, maximum: i32) Knob {
        return .{
            .value = value,
            .minimum = minimum,
            .maximum = maximum,
        };
    }

    pub fn change(self: *Knob, amount: i32) void {
        self.value += amount;

        if (self.value < self.minimum) {
            self.value = self.minimum;
        }

        if (self.value > self.maximum) {
            self.value = self.maximum;
        }
    }

    pub fn isSolved(self: Knob) bool {
        return self.value == 0;
    }
};
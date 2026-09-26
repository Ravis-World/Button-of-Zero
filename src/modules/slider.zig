pub const Slider = struct {
    value: i32,
    minimum: i32,
    maximum: i32,

    pub fn init(value: i32, minimum: i32, maximum: i32) Slider {
        return .{
            .value = value,
            .minimum = minimum,
            .maximum = maximum,
        };
    }

    pub fn setValue(self: *Slider, value: i32) void {
        self.value = @max(self.minimum, @min(self.maximum, value));
    }

    pub fn isSolved(self: Slider) bool {
        return self.value == 0;
    }
};
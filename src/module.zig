const std = @import("std");

pub const ModuleType = enum {
    slider,
    knob,
    number_box,
    dropdown,
    counter,
    equation,
    toggle,
    sequence,
    logic,
};

pub const ModuleTier = enum {
    basic,
    intermediate,
    advanced,
};

// Sub-component structs
pub const Slider = struct {
    value: i32,
    minimum: i32,
    maximum: i32,

    pub fn init(value: i32, minimum: i32, maximum: i32) Slider {
        return .{ .value = value, .minimum = minimum, .maximum = maximum };
    }
    pub fn setValue(self: *Slider, val: i32) void {
        self.value = @max(self.minimum, @min(self.maximum, val));
    }
    pub fn isSolved(self: Slider) bool {
        return self.value == 0;
    }
};

pub const Knob = struct {
    value: i32,
    minimum: i32,
    maximum: i32,

    pub fn init(value: i32, minimum: i32, maximum: i32) Knob {
        return .{ .value = value, .minimum = minimum, .maximum = maximum };
    }
    pub fn change(self: *Knob, amount: i32) void {
        self.value = @max(self.minimum, @min(self.maximum, self.value + amount));
    }
    pub fn isSolved(self: Knob) bool {
        return self.value == 0;
    }
};

pub const NumberBox = struct {
    value: i32,

    pub fn init(value: i32) NumberBox {
        return .{ .value = value };
    }
    pub fn setValue(self: *NumberBox, val: i32) void {
        self.value = val;
    }
    pub fn isSolved(self: NumberBox) bool {
        return self.value == 0;
    }
};

pub const Dropdown = struct {
    selected: i32,
    option_count: i32,

    pub fn init(option_count: i32, selected: i32) Dropdown {
        return .{ .selected = selected, .option_count = option_count };
    }
    pub fn select(self: *Dropdown, val: i32) void {
        if (val >= 0 and val < self.option_count) {
            self.selected = val;
        }
    }
    pub fn isSolved(self: Dropdown) bool {
        return self.selected == 0;
    }
};

pub const Counter = struct {
    value: i32,

    pub fn init(value: i32) Counter {
        return .{ .value = value };
    }
    pub fn increment(self: *Counter) void {
        self.value += 1;
    }
    pub fn decrement(self: *Counter) void {
        if (self.value > 0) self.value -= 1;
    }
    pub fn isSolved(self: Counter) bool {
        return self.value == 0;
    }
};

pub const Equation = struct {
    left: i32,
    right: i32,
    result: i32,

    pub fn init(left: i32, right: i32) Equation {
        return .{ .left = left, .right = right, .result = left + right };
    }
    pub fn changeLeft(self: *Equation, amount: i32) void {
        self.left += amount;
        self.updateResult();
    }
    pub fn changeRight(self: *Equation, amount: i32) void {
        self.right += amount;
        self.updateResult();
    }
    fn updateResult(self: *Equation) void {
        self.result = self.left + self.right;
    }
    pub fn isSolved(self: Equation) bool {
        return self.result == 0;
    }
};

pub const Toggle = struct {
    enabled: bool,

    pub fn init(enabled: bool) Toggle {
        return .{ .enabled = enabled };
    }
    pub fn toggle(self: *Toggle) void {
        self.enabled = !self.enabled;
    }
    pub fn value(self: Toggle) i32 {
        return if (self.enabled) 1 else 0;
    }
    pub fn isSolved(self: Toggle) bool {
        return !self.enabled;
    }
};

pub const Sequence = struct {
    values: [5]i32,
    selected: usize,

    pub fn init(values: [5]i32) Sequence {
        return .{ .values = values, .selected = 0 };
    }
    pub fn changeValue(self: *Sequence, amount: i32) void {
        self.values[self.selected] += amount;
    }
    pub fn select(self: *Sequence, index: usize) void {
        if (index < self.values.len) self.selected = index;
    }
    pub fn isSolved(self: Sequence) bool {
        for (self.values) |val| {
            if (val != 0) return false;
        }
        return true;
    }
};

pub const Logic = struct {
    values: [4]bool,

    pub fn init(values: [4]bool) Logic {
        return .{ .values = values };
    }
    pub fn toggle(self: *Logic, index: usize) void {
        if (index < self.values.len) {
            self.values[index] = !self.values[index];
        }
    }
    pub fn isSolved(self: Logic) bool {
        for (self.values) |val| {
            if (val) return false;
        }
        return true;
    }
};

// Master Module container union/struct used by Game
pub const Module = struct {
    module_type: ModuleType,
    tier: ModuleTier,
    solved: bool = false,

    slider: Slider = .{ .value = 0, .minimum = 0, .maximum = 100 },
    knob: Knob = .{ .value = 0, .minimum = 0, .maximum = 100 },
    number_box: NumberBox = .{ .value = 0 },
    dropdown: Dropdown = .{ .selected = 0, .option_count = 4 },
    counter: Counter = .{ .value = 0 },
    equation: Equation = .{ .left = 0, .right = 0, .result = 0 },
    toggle: Toggle = .{ .enabled = false },
    sequence: Sequence = .{ .values = .{0} ** 5, .selected = 0 },
    logic: Logic = .{ .values = .{false} ** 4 },

    pub fn getValue(self: Module) i32 {
        return switch (self.module_type) {
            .slider => self.slider.value,
            .knob => self.knob.value,
            .number_box => self.number_box.value,
            .dropdown => self.dropdown.selected,
            .counter => self.counter.value,
            .equation => self.equation.result,
            .toggle => self.toggle.value(),
            .sequence => self.sequence.values[self.sequence.selected],
            .logic => @intFromBool(self.logic.values[0]),
        };
    }

    pub fn setValue(self: *Module, value: i32) void {
        switch (self.module_type) {
            .slider => self.slider.setValue(value),
            .knob => self.knob.value = @max(self.knob.minimum, @min(self.knob.maximum, value)),
            .number_box => self.number_box.setValue(value),
            .dropdown => self.dropdown.select(value),
            .counter => self.counter.value = @max(0, value),
            .equation => self.equation.changeLeft(value - self.equation.result),
            .toggle => self.toggle.enabled = value != 0,
            .sequence => self.sequence.values[self.sequence.selected] = value,
            .logic => self.logic.values[0] = value != 0,
        }
    }

    pub fn changeValue(self: *Module, amount: i32) void {
        switch (self.module_type) {
            .slider => self.slider.setValue(self.slider.value + amount),
            .knob => {
                if (amount > 0 and self.knob.value >= self.knob.maximum) {
                    self.knob.value = self.knob.minimum;
                } else {
                    self.knob.change(amount);
                }
            },
            .number_box => self.number_box.setValue(self.number_box.value + amount),
            .dropdown => self.dropdown.select(@mod(self.dropdown.selected + amount, self.dropdown.option_count)),
            .counter => {
                if (amount > 0) {
                    self.counter.increment();
                } else if (amount < 0) {
                    self.counter.decrement();
                }
            },
            .equation => self.equation.changeLeft(amount),
            .toggle => self.toggle.toggle(),
            .sequence => self.sequence.changeValue(amount),
            .logic => if (amount != 0) self.logic.toggle(0),
        }
    }

    pub fn updateSolved(self: *Module) void {
        self.solved = switch (self.module_type) {
            .slider => self.slider.isSolved(),
            .knob => self.knob.isSolved(),
            .number_box => self.number_box.isSolved(),
            .dropdown => self.dropdown.isSolved(),
            .counter => self.counter.isSolved(),
            .equation => self.equation.isSolved(),
            .toggle => self.toggle.isSolved(),
            .sequence => self.sequence.isSolved(),
            .logic => self.logic.isSolved(),
        };
    }
};

pub fn getTier(module_type: ModuleType) ModuleTier {
    return switch (module_type) {
        .slider, .number_box, .counter => .basic,
        .knob, .dropdown, .equation, .toggle => .intermediate,
        .sequence, .logic => .advanced,
    };
}

pub fn createModule(module_type: ModuleType, random: *std.Random) Module {
    const tier = getTier(module_type);
    const r1 = random.intRangeAtMost(i32, 1, 20);
    const r2 = random.intRangeAtMost(i32, 1, 20);

    var mod = Module{
        .module_type = module_type,
        .tier = tier,
        .slider = Slider.init(r1, 0, 100),
        .knob = Knob.init(r1, 0, 100),
        .number_box = NumberBox.init(r1),
        .dropdown = Dropdown.init(4, @intCast(random.intRangeAtMost(u32, 1, 3))),
        .counter = Counter.init(r1),
        .equation = Equation.init(r1, r2),
        .toggle = Toggle.init(true),
        .sequence = Sequence.init(.{ r1, r2, r1, r2, r1 }),
        .logic = Logic.init(.{
            random.boolean(),
            random.boolean(),
            random.boolean(),
            random.boolean(),
        }),
    };

    mod.updateSolved();
    return mod;
}

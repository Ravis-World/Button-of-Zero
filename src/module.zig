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

pub const Module = struct {
module_type: ModuleType,
tier: ModuleTier,

value: i32 = 0,
target: i32 = 0,
solved: bool = false,

pub fn updateSolved(self: *Module) void {
    self.solved = self.value == self.target;
}

pub fn changeValue(self: *Module, amount: i32) void {
    self.value += amount;

    if (self.value < 0) {
        self.value = 0;
    }

    self.updateSolved();
}


};

pub fn getTier(module_type: ModuleType) ModuleTier {
return switch (module_type) {
.slider,
.number_box,
.counter => .basic,

    .knob,
    .dropdown,
    .equation,
    .toggle => .intermediate,

    .sequence,
    .logic => .advanced,
};


}

pub fn createModule(
module_type: ModuleType,
random: *std.Random,
) Module {
var module = Module{
.module_type = module_type,
.tier = getTier(module_type),
.value = random.intRangeAtMost(i32, 1, 100),
.target = 0,
};

module.updateSolved();

return module;


}
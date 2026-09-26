const ModuleType = @import("module.zig").ModuleType;
const TimerSong = @import("timer.zig").TimerSong;

pub const Difficulty = enum {
easy,
medium,
hard,

pub fn minModules(self: Difficulty) u32 {
    return switch (self) {
        .easy => 5,
        .medium => 8,
        .hard => 12,
    };
}

pub fn maxModules(self: Difficulty) u32 {
    return switch (self) {
        .easy => 7,
        .medium => 15,
        .hard => 20,
    };
}

pub fn timerSeconds(self: Difficulty) u32 {
    return switch (self) {
        .easy => 90,
        .medium => 150,
        .hard => 240,
    };
}

pub fn timerSong(self: Difficulty) TimerSong {
    return switch (self) {
        .easy => .easy,
        .medium => .medium,
        .hard => .hard,
    };
}

pub fn availableModules(self: Difficulty) []const ModuleType {
    return switch (self) {
        .easy => &[_]ModuleType{
            .slider,
            .number_box,
            .counter,
        },

        .medium => &[_]ModuleType{
            .slider,
            .number_box,
            .counter,
            .knob,
            .dropdown,
            .equation,
            .toggle,
        },

        .hard => &[_]ModuleType{
            .slider,
            .number_box,
            .counter,
            .knob,
            .dropdown,
            .equation,
            .toggle,
            .sequence,
            .logic,
        },
    };
}


};
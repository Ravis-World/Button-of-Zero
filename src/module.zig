pub const ModuleType = enum {
    slider,
    knob,
    number_box,
    dropdown,
    counter,
    equation,
    sequence,
    logic,
};

pub const DifficultyTier = enum {
    basic,
    intermediate,
    advanced,
};

pub fn tier(module_type: ModuleType) DifficultyTier {
    return switch (module_type) {
        .slider,
        .number_box,
        .counter => .basic,

        .knob,
        .dropdown,
        .equation => .intermediate,

        .sequence,
        .logic => .advanced,
    };
}
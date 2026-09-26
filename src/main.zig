const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const GameState = @import("game.zig").GameState;
const Difficulty = @import("difficulty.zig").Difficulty;
const ModuleType = @import("module.zig").ModuleType;
const Module = @import("module.zig").Module;

const Screen = enum {
    difficulty_select,
    game,
    game_over,
    success,
};

var screen: Screen = .difficulty_select;
var game: ?Game = null;
var scroll_offset: f32 = 0;
var scrollbar_dragging = false;
var scrollbar_drag_start_y: f32 = 0;
var scrollbar_drag_start_offset: f32 = 0;
var active_number_box_module: ?usize = null;

const header_height: f32 = 110;
const module_height: f32 = 100;
const module_spacing: f32 = 15;
const module_area_padding: f32 = 20;

pub fn main() !void {
    rl.initWindow(1280, 720, "Button of Zero");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var prng = std.Random.DefaultPrng.init(@intFromFloat(rl.getTime() * 1_000_000_000.0));
    const random = prng.random();

    while (!rl.windowShouldClose()) {
        const delta_time = rl.getFrameTime();
        handleGlobalInput();

        switch (screen) {
            .difficulty_select => {
                handleDifficultyInput(random);
            },
            .game => {
                if (game) |*current_game| {
                    handleGameInput(current_game);
                    current_game.update(delta_time);
                    if (current_game.state == .game_over) {
                        screen = .game_over;
                    } else if (current_game.state == .success) {
                        screen = .success;
                    }
                }
            },
            .game_over => {
                handleEndScreenInput(random);
            },
            .success => {
                handleEndScreenInput(random);
            },
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        switch (screen) {
            .difficulty_select => drawDifficultySelect(),
            .game => drawGame(),
            .game_over => drawGameOver(),
            .success => drawSuccess(),
        }
    }
}

fn handleGlobalInput() void {
    if (rl.isKeyPressed(.f11)) {
        rl.toggleFullscreen();
    }
}

fn handleDifficultyInput(random: std.Random) void {
    const mouse = rl.getMousePosition();
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));

    const button_width: f32 = 300;
    const button_height: f32 = 70;
    const button_x = (screen_width - button_width) / 2;
    const easy_y = screen_height / 2 - 130;
    const medium_y = screen_height / 2 - 35;
    const hard_y = screen_height / 2 + 60;

    if (rl.isMouseButtonPressed(.left)) {
        if (pointInRectangle(mouse, button_x, easy_y, button_width, button_height)) {
            startGame(.easy, random);
        } else if (pointInRectangle(mouse, button_x, medium_y, button_width, button_height)) {
            startGame(.medium, random);
        } else if (pointInRectangle(mouse, button_x, hard_y, button_width, button_height)) {
            startGame(.hard, random);
        }
    }
}

fn startGame(difficulty: Difficulty, random: std.Random) void {
    game = Game.init(difficulty, random);
    scroll_offset = 0;
    scrollbar_dragging = false;
    active_number_box_module = null;
    screen = .game;
}

fn handleGameInput(current_game: *Game) void {
    handleScrolling(current_game);
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const module_area_top = header_height;
    const module_area_bottom = screen_height - 20;

    if (active_number_box_module) |idx| {
        if (idx < current_game.moduleCount()) {
            var mod = &current_game.modules[idx];
            if (mod.module_type == .number_box) {
                if (rl.isKeyPressed(.backspace)) {
                    mod.value = 0;
                    mod.updateSolved();
                } else {
                    const keys = [_]rl.KeyboardKey{
                        .zero, .one, .two,   .three, .four,
                        .five, .six, .seven, .eight, .nine,
                    };
                    for (keys, 0..) |key, d| {
                        if (rl.isKeyPressed(key)) {
                            mod.value = mod.value * 10 + @as(i32, @intCast(d));
                            if (mod.value > 9999) mod.value = 9999;
                            mod.updateSolved();
                        }
                    }
                }
            }
        }
    }

    if (rl.isMouseButtonPressed(.left)) {
        var clicked_on_any_number_box = false;
        for (0..current_game.moduleCount()) |index| {
            const module_y = module_area_top +
                module_area_padding +
                @as(f32, @floatFromInt(index)) * (module_height + module_spacing) -
                scroll_offset;

            if (module_y + module_height < module_area_top or module_y > module_area_bottom) {
                continue;
            }

            if (current_game.modules[index].module_type == .number_box) {
                const box_x: f32 = 350;
                const box_y = module_y + 30;
                const box_w: f32 = 120;
                const box_h: f32 = 40;
                const mouse = rl.getMousePosition();
                if (pointInRectangle(mouse, box_x, box_y, box_w, box_h)) {
                    active_number_box_module = index;
                    clicked_on_any_number_box = true;
                }
            }
        }
        if (!clicked_on_any_number_box) {
            active_number_box_module = null;
        }
    }

    for (0..current_game.moduleCount()) |index| {
        const module_y = module_area_top +
            module_area_padding +
            @as(f32, @floatFromInt(index)) * (module_height + module_spacing) -
            scroll_offset;

        if (module_y + module_height < module_area_top) {
            continue;
        }
        if (module_y > module_area_bottom) {
            continue;
        }

        handleModuleInput(
            &current_game.modules[index],
            module_y,
        );
    }
}

fn handleScrolling(current_game: *Game) void {
    const mouse = rl.getMousePosition();
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const module_area_top = header_height;
    const module_area_bottom = screen_height - 20;
    const viewport_height = module_area_bottom - module_area_top;
    const content_height =
        module_area_padding +
        @as(f32, @floatFromInt(current_game.moduleCount())) *
            (module_height + module_spacing);

    const max_scroll = @max(0.0, content_height - viewport_height);
    const wheel = rl.getMouseWheelMove();

    if (wheel != 0 and mouse.y >= module_area_top and mouse.y <= module_area_bottom) {
        scroll_offset -= wheel * 50;
        if (scroll_offset < 0) {
            scroll_offset = 0;
        }
        if (scroll_offset > max_scroll) {
            scroll_offset = max_scroll;
        }
    }

    if (content_height <= viewport_height) {
        scroll_offset = 0;
        scrollbar_dragging = false;
        return;
    }

    const scrollbar_x = screen_width - 25;
    const scrollbar_width: f32 = 15;
    const track_height = viewport_height;
    const thumb_height = @max(
        40.0,
        track_height * viewport_height / content_height,
    );
    const available_thumb_movement = track_height - thumb_height;
    var thumb_y = module_area_top;

    if (max_scroll > 0) {
        thumb_y += (scroll_offset / max_scroll) * available_thumb_movement;
    }

    if (rl.isMouseButtonPressed(.left)) {
        if (pointInRectangle(
            mouse,
            scrollbar_x,
            thumb_y,
            scrollbar_width,
            thumb_height,
        )) {
            scrollbar_dragging = true;
            scrollbar_drag_start_y = mouse.y;
            scrollbar_drag_start_offset = scroll_offset;
        }
    }

    if (!rl.isMouseButtonDown(.left)) {
        scrollbar_dragging = false;
    }

    if (scrollbar_dragging) {
        const mouse_delta = mouse.y - scrollbar_drag_start_y;
        if (available_thumb_movement > 0) {
            scroll_offset =
                scrollbar_drag_start_offset +
                (mouse_delta / available_thumb_movement) * max_scroll;
        }
        if (scroll_offset < 0) {
            scroll_offset = 0;
        }
        if (scroll_offset > max_scroll) {
            scroll_offset = max_scroll;
        }
    }
}

fn handleModuleInput(module: *Module, module_y: f32) void {
    const mouse = rl.getMousePosition();
    switch (module.module_type) {
        .slider => {
            const slider_x: f32 = 300;
            const slider_width: f32 = 400;
            const slider_y = module_y + 50;
            const slider_height: f32 = 20;

            if (rl.isMouseButtonDown(.left)) {
                if (pointInRectangle(
                    mouse,
                    slider_x - 10,
                    slider_y - 10,
                    slider_width + 20,
                    slider_height + 20,
                )) {
                    var value =
                        ((mouse.x - slider_x) / slider_width) * 100.0;
                    if (value < 0) {
                        value = 0;
                    }
                    if (value > 100) {
                        value = 100;
                    }
                    module.value = @intFromFloat(value);
                    module.updateSolved();
                }
            }
        },
        .number_box => {
            const minus_x: f32 = 300;
            const plus_x: f32 = 480;
            const button_y = module_y + 30;
            const button_width: f32 = 40;
            const button_height: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, minus_x, button_y, button_width, button_height)) {
                    module.changeValue(-1);
                }
                if (pointInRectangle(mouse, plus_x, button_y, button_width, button_height)) {
                    module.changeValue(1);
                }
            }
        },
        .counter => {
            const minus_x: f32 = 300;
            const plus_x: f32 = 500;
            const button_y = module_y + 30;
            const button_width: f32 = 40;
            const button_height: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, minus_x, button_y, button_width, button_height)) {
                    module.changeValue(-1);
                }
                if (pointInRectangle(mouse, plus_x, button_y, button_width, button_height)) {
                    module.changeValue(1);
                }
            }
        },
        .knob => {
            const knob_x: f32 = 350;
            const knob_y = module_y + 50;
            const radius: f32 = 25;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInCircle(mouse, knob_x, knob_y, radius)) {
                    module.changeValue(1);
                    if (module.value > 100) module.value = 0;
                }
            }
        },
        .dropdown => {
            const drop_x: f32 = 350;
            const drop_y = module_y + 30;
            const drop_w: f32 = 200;
            const drop_h: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, drop_x, drop_y, drop_w, drop_h)) {
                    module.changeValue(1);
                    if (module.value > 5) module.value = 0;
                }
            }
        },
        .equation => {
            const eq_x: f32 = 350;
            const eq_y = module_y + 30;
            const eq_w: f32 = 150;
            const eq_h: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, eq_x, eq_y, eq_w, eq_h)) {
                    module.changeValue(1);
                }
            }
        },
        .toggle => {
            const tog_x: f32 = 350;
            const tog_y = module_y + 30;
            const tog_w: f32 = 100;
            const tog_h: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, tog_x, tog_y, tog_w, tog_h)) {
                    module.value = if (module.value == 0) 1 else 0;
                    module.updateSolved();
                }
            }
        },
        .sequence => {
            const seq_x: f32 = 350;
            const seq_y = module_y + 30;
            const seq_w: f32 = 150;
            const seq_h: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, seq_x, seq_y, seq_w, seq_h)) {
                    module.changeValue(1);
                }
            }
        },
        .logic => {
            const log_x: f32 = 350;
            const log_y = module_y + 30;
            const log_w: f32 = 150;
            const log_h: f32 = 40;

            if (rl.isMouseButtonPressed(.left)) {
                if (pointInRectangle(mouse, log_x, log_y, log_w, log_h)) {
                    module.changeValue(1);
                }
            }
        },
    }
}

fn drawDifficultySelect() void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));

    drawCenteredText(
        "BUTTON OF ZERO",
        screen_width,
        50,
        40,
        rl.Color.black,
    );
    drawCenteredText(
        "SELECT DIFFICULTY",
        screen_width,
        110,
        25,
        rl.Color.black,
    );

    const button_width: f32 = 300;
    const button_height: f32 = 70;
    const button_x = (screen_width - button_width) / 2;
    const easy_y = screen_height / 2 - 130;
    const medium_y = screen_height / 2 - 35;
    const hard_y = screen_height / 2 + 60;

    drawDifficultyButton(
        button_x,
        easy_y,
        button_width,
        button_height,
        "EASY - 90 SECONDS",
    );
    drawDifficultyButton(
        button_x,
        medium_y,
        button_width,
        button_height,
        "MEDIUM - 150 SECONDS",
    );
    drawDifficultyButton(
        button_x,
        hard_y,
        button_width,
        button_height,
        "HARD - 240 SECONDS",
    );

    drawCenteredText(
        "F11: FULLSCREEN",
        screen_width,
        screen_height - 45,
        20,
        rl.Color.black,
    );
}

fn drawDifficultyButton(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    text: []const u8,
) void {
    rl.drawRectangle(
        @intFromFloat(x),
        @intFromFloat(y),
        @intFromFloat(width),
        @intFromFloat(height),
        rl.Color.light_gray,
    );
    rl.drawRectangleLines(
        @intFromFloat(x),
        @intFromFloat(y),
        @intFromFloat(width),
        @intFromFloat(height),
        rl.Color.black,
    );

    const font_size: i32 = 20;
    var buffer: [256:0]u8 = undefined;
    const text_z = std.fmt.bufPrintZ(&buffer, "{s}", .{text}) catch return;
    const text_width = @as(f32, @floatFromInt(rl.measureText(text_z, font_size)));
    const text_height = @as(f32, @floatFromInt(font_size));

    const text_x = x + (width - text_width) / 2;
    const text_y = y + (height - text_height) / 2;

    rl.drawText(
        text_z,
        @intFromFloat(text_x),
        @intFromFloat(text_y),
        font_size,
        rl.Color.black,
    );
}

fn drawGame() void {
    if (game) |current_game| {
        const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));

        drawGameHeader(current_game);

        const module_area_top = header_height;
        const module_area_bottom = screen_height - 20;

        for (0..current_game.moduleCount()) |index| {
            const module_y = module_area_top +
                module_area_padding +
                @as(f32, @floatFromInt(index)) *
                    (module_height + module_spacing) -
                scroll_offset;

            if (module_y + module_height < module_area_top) {
                continue;
            }
            if (module_y > module_area_bottom) {
                continue;
            }

            drawModule(
                &current_game.modules[index],
                index,
                module_y,
                screen_width,
            );
        }

        drawScrollbar(current_game);
    }
}

fn drawGameHeader(current_game: Game) void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    rl.drawRectangle(
        0,
        0,
        @intFromFloat(screen_width),
        @intFromFloat(header_height),
        rl.Color.light_gray,
    );

    drawText(
        "BUTTON OF ZERO",
        20,
        15,
        30,
        rl.Color.black,
    );
    drawText(
        "Modules: ",
        20,
        55,
        20,
        rl.Color.black,
    );
    drawNumber(
        @intCast(current_game.moduleCount()),
        105,
        55,
        20,
        rl.Color.black,
    );

    drawText(
        "Time: ",
        screen_width - 180,
        20,
        20,
        rl.Color.black,
    );
    drawNumber(
        @intCast(current_game.timer.seconds()),
        screen_width - 110,
        20,
        25,
        rl.Color.black,
    );
    drawText(
        "F11: Fullscreen",
        screen_width - 180,
        55,
        15,
        rl.Color.black,
    );
}

fn drawModule(
    module: *const Module,
    index: usize,
    y: f32,
    screen_width: f32,
) void {
    const x: f32 = 20;
    const width = screen_width - 70;

    rl.drawRectangle(
        @intFromFloat(x),
        @intFromFloat(y),
        @intFromFloat(width),
        @intFromFloat(module_height),
        rl.Color.light_gray,
    );
    rl.drawRectangleLines(
        @intFromFloat(x),
        @intFromFloat(y),
        @intFromFloat(width),
        @intFromFloat(module_height),
        rl.Color.black,
    );

    drawText(
        "MOD",
        x + 15,
        y + 10,
        15,
        rl.Color.black,
    );
    drawNumber(
        @intCast(index + 1),
        x + 55,
        y + 10,
        15,
        rl.Color.black,
    );

    switch (module.module_type) {
        .slider => drawSlider(module, y),
        .number_box => drawNumberBox(module, index, y),
        .counter => drawCounter(module, y),
        .knob => drawKnob(module, y),
        .dropdown => drawDropdown(module, y),
        .equation => drawEquation(module, y),
        .toggle => drawToggle(module, y),
        .sequence => drawSequence(module, y),
        .logic => drawLogic(module, y),
    }

    if (module.solved) {
        drawText(
            "ZEROED",
            width - 50,
            y + 10,
            15,
            rl.Color.dark_green,
        );
    }
}

fn drawSlider(module: *const Module, y: f32) void {
    drawText(
        "SLIDER",
        110,
        y + 10,
        20,
        rl.Color.black,
    );

    const slider_x: f32 = 300;
    const slider_y = y + 50;
    const slider_width: f32 = 400;
    const slider_height: f32 = 20;

    rl.drawRectangle(
        @intFromFloat(slider_x),
        @intFromFloat(slider_y),
        @intFromFloat(slider_width),
        @intFromFloat(slider_height),
        rl.Color.gray,
    );

    const position =
        slider_x +
        (@as(f32, @floatFromInt(module.value)) / 100.0) *
            slider_width;

    rl.drawCircle(
        @intFromFloat(position),
        @intFromFloat(slider_y + slider_height / 2),
        12,
        rl.Color.black,
    );

    drawNumber(
        module.value,
        720,
        y + 45,
        20,
        rl.Color.black,
    );
}

fn drawNumberBox(module: *const Module, index: usize, y: f32) void {
    drawText(
        "NUMBER BOX",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    drawText(
        "-",
        312,
        y + 37,
        25,
        rl.Color.black,
    );

    const box_x: f32 = 350;
    const box_y = y + 30;
    const box_w: f32 = 120;
    const box_h: f32 = 40;

    const is_active = if (active_number_box_module) |active_idx| active_idx == index else false;

    rl.drawRectangle(
        @intFromFloat(box_x),
        @intFromFloat(box_y),
        @intFromFloat(box_w),
        @intFromFloat(box_h),
        rl.Color.white,
    );
    rl.drawRectangleLines(
        @intFromFloat(box_x),
        @intFromFloat(box_y),
        @intFromFloat(box_w),
        @intFromFloat(box_h),
        if (is_active) rl.Color.blue else rl.Color.black,
    );

    drawNumber(
        module.value,
        box_x + 15,
        box_y + 8,
        20,
        rl.Color.black,
    );

    drawText(
        "+",
        492,
        y + 37,
        25,
        rl.Color.black,
    );
    rl.drawRectangleLines(
        300,
        @intFromFloat(y + 30),
        40,
        40,
        rl.Color.black,
    );
    rl.drawRectangleLines(
        480,
        @intFromFloat(y + 30),
        40,
        40,
        rl.Color.black,
    );
}

fn drawCounter(module: *const Module, y: f32) void {
    drawText(
        "COUNTER",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    drawText(
        "-",
        312,
        y + 37,
        25,
        rl.Color.black,
    );
    drawNumber(
        module.value,
        370,
        y + 38,
        20,
        rl.Color.black,
    );
    drawText(
        "+",
        512,
        y + 37,
        25,
        rl.Color.black,
    );
    rl.drawRectangleLines(
        300,
        @intFromFloat(y + 30),
        40,
        40,
        rl.Color.black,
    );
    rl.drawRectangleLines(
        500,
        @intFromFloat(y + 30),
        40,
        40,
        rl.Color.black,
    );
}

fn drawKnob(module: *const Module, y: f32) void {
    drawText(
        "KNOB",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    rl.drawCircle(
        350,
        @intFromFloat(y + 50),
        25,
        rl.Color.gray,
    );
    drawNumber(
        module.value,
        400,
        y + 40,
        20,
        rl.Color.black,
    );
}

fn drawDropdown(module: *const Module, y: f32) void {
    drawText(
        "DROPDOWN",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    rl.drawRectangleLines(
        350,
        @intFromFloat(y + 30),
        200,
        40,
        rl.Color.black,
    );
    drawNumber(
        module.value,
        370,
        y + 40,
        20,
        rl.Color.black,
    );
}

fn drawEquation(module: *const Module, y: f32) void {
    drawText(
        "EQUATION",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    drawNumber(
        module.value,
        350,
        y + 40,
        20,
        rl.Color.black,
    );
    drawText(
        "= 0",
        400,
        y + 40,
        20,
        rl.Color.black,
    );
}

fn drawToggle(module: *const Module, y: f32) void {
    drawText(
        "TOGGLE",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    if (module.value != 0) {
        rl.drawRectangle(
            350,
            @intFromFloat(y + 30),
            100,
            40,
            rl.Color.gray,
        );
    } else {
        rl.drawRectangleLines(
            350,
            @intFromFloat(y + 30),
            100,
            40,
            rl.Color.black,
        );
    }
}

fn drawSequence(module: *const Module, y: f32) void {
    drawText(
        "SEQUENCE",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    drawNumber(
        module.value,
        350,
        y + 40,
        20,
        rl.Color.black,
    );
}

fn drawLogic(module: *const Module, y: f32) void {
    drawText(
        "LOGIC",
        110,
        y + 10,
        20,
        rl.Color.black,
    );
    drawNumber(
        module.value,
        350,
        y + 40,
        20,
        rl.Color.black,
    );
}

fn drawScrollbar(current_game: Game) void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const module_area_top = header_height;
    const module_area_bottom = screen_height - 20;
    const viewport_height = module_area_bottom - module_area_top;
    const content_height =
        module_area_padding +
        @as(f32, @floatFromInt(current_game.moduleCount())) *
            (module_height + module_spacing);

    if (content_height <= viewport_height) {
        return;
    }

    const scrollbar_x = screen_width - 25;
    const scrollbar_width: f32 = 15;
    rl.drawRectangle(
        @intFromFloat(scrollbar_x),
        @intFromFloat(module_area_top),
        @intFromFloat(scrollbar_width),
        @intFromFloat(viewport_height),
        rl.Color.gray,
    );

    const thumb_height = @max(
        40.0,
        viewport_height * viewport_height / content_height,
    );
    const max_scroll = content_height - viewport_height;
    const available_movement = viewport_height - thumb_height;
    var thumb_y = module_area_top;

    if (max_scroll > 0) {
        thumb_y +=
            (scroll_offset / max_scroll) *
            available_movement;
    }

    rl.drawRectangle(
        @intFromFloat(scrollbar_x),
        @intFromFloat(thumb_y),
        @intFromFloat(scrollbar_width),
        @intFromFloat(thumb_height),
        rl.Color.black,
    );
}

fn drawGameOver() void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));

    drawCenteredText(
        "GAME OVER",
        screen_width,
        screen_height / 2 - 80,
        50,
        rl.Color.black,
    );
    drawCenteredText(
        "TIME RAN OUT",
        screen_width,
        screen_height / 2 - 20,
        25,
        rl.Color.black,
    );
    drawCenteredText(
        "CLICK TO RETURN TO DIFFICULTY SELECT",
        screen_width,
        screen_height / 2 + 60,
        20,
        rl.Color.black,
    );
}

fn drawSuccess() void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));

    drawCenteredText(
        "SUCCESS!",
        screen_width,
        screen_height / 2 - 80,
        50,
        rl.Color.black,
    );
    drawCenteredText(
        "ALL MODULES ZEROED",
        screen_width,
        screen_height / 2 - 20,
        25,
        rl.Color.black,
    );
    drawCenteredText(
        "CLICK TO RETURN TO DIFFICULTY SELECT",
        screen_width,
        screen_height / 2 + 60,
        20,
        rl.Color.black,
    );
}

fn handleEndScreenInput(random: std.Random) void {
    if (rl.isMouseButtonPressed(.left)) {
        game = null;
        scroll_offset = 0;
        scrollbar_dragging = false;
        active_number_box_module = null;
        screen = .difficulty_select;
    }
    if (rl.isKeyPressed(.enter)) {
        game = null;
        scroll_offset = 0;
        scrollbar_dragging = false;
        active_number_box_module = null;
        screen = .difficulty_select;
        _ = random;
    }
}

fn pointInRectangle(
    point: rl.Vector2,
    x: f32,
    y: f32,
    width: f32,
    height: f32,
) bool {
    return point.x >= x and
        point.x <= x + width and
        point.y >= y and
        point.y <= y + height;
}

fn pointInCircle(
    point: rl.Vector2,
    cx: f32,
    cy: f32,
    radius: f32,
) bool {
    const dx = point.x - cx;
    const dy = point.y - cy;
    return (dx * dx + dy * dy) <= (radius * radius);
}

fn drawText(
    text: []const u8,
    x: f32,
    y: f32,
    font_size: i32,
    color: rl.Color,
) void {
    var buffer: [256:0]u8 = undefined;
    const text_z = std.fmt.bufPrintZ(
        &buffer,
        "{s}",
        .{text},
    ) catch return;
    rl.drawText(
        text_z,
        @intFromFloat(x),
        @intFromFloat(y),
        font_size,
        color,
    );
}

fn drawNumber(
    number: i32,
    x: f32,
    y: f32,
    font_size: i32,
    color: rl.Color,
) void {
    var buffer: [64:0]u8 = undefined;
    const text_z = std.fmt.bufPrintZ(
        &buffer,
        "{d}",
        .{number},
    ) catch return;
    rl.drawText(
        text_z,
        @intFromFloat(x),
        @intFromFloat(y),
        font_size,
        color,
    );
}

fn drawCenteredText(
    text: []const u8,
    width: f32,
    y: f32,
    font_size: i32,
    color: rl.Color,
) void {
    var buffer: [256:0]u8 = undefined;
    const text_z = std.fmt.bufPrintZ(
        &buffer,
        "{s}",
        .{text},
    ) catch return;
    const text_width = @as(
        f32,
        @floatFromInt(rl.measureText(text_z, font_size)),
    );
    const x = (width - text_width) / 2;
    rl.drawText(
        text_z,
        @intFromFloat(x),
        @intFromFloat(y),
        font_size,
        color,
    );
}

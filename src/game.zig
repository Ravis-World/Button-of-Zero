const std = @import("std");
const Difficulty = @import("difficulty.zig").Difficulty;
const Module = @import("module.zig").Module;
const ModuleType = @import("module.zig").ModuleType;
const createModule = @import("module.zig").createModule;
const Timer = @import("timer.zig").Timer;
const TimerSong = @import("timer.zig").TimerSong;
const Audio = @import("audio.zig").Audio;
const Music = @import("audio.zig").Music;

pub const GameState = enum {
playing,
game_over,
success,
};

pub const Game = struct {
difficulty: Difficulty,
timer: Timer,
audio: Audio,
state: GameState,

modules: [20]Module,
module_count: usize,

random: std.Random,

pub fn init(difficulty: Difficulty, random: std.Random) Game {
    const timer_song: TimerSong = switch (difficulty) {
        .easy => .easy,
        .medium => .medium,
        .hard => .hard,
    };

    var game = Game{
        .difficulty = difficulty,
        .timer = Timer.init(difficulty.timerSeconds(), timer_song),
        .audio = .{},
        .state = .playing,
        .modules = undefined,
        .module_count = 0,
        .random = random,
    };

    game.generateModules();
    game.startCountdownMusic();

    return game;
}

fn generateModules(self: *Game) void {
    const minimum = self.difficulty.minModules();
    const maximum = self.difficulty.maxModules();

    const count = self.random.intRangeAtMost(
        u32,
        minimum,
        maximum,
    );

    const available = self.difficulty.availableModules();

    self.module_count = @intCast(count);

    for (0..self.module_count) |index| {
        const type_index = self.random.uintLessThan(usize, available.len);
        const module_type: ModuleType = available[type_index];

        self.modules[index] = createModule(
            module_type,
            &self.random,
        );
    }
}

fn startCountdownMusic(self: *Game) void {
    const music: Music = switch (self.difficulty) {
        .easy => .countdown_easy,
        .medium => .countdown_medium,
        .hard => .countdown_hard,
    };

    self.audio.play(music);
}

pub fn update(self: *Game, delta_time: f32) void {
    if (self.state != .playing) {
        return;
    }

    self.timer.update(delta_time);

    if (self.timer.isFinished()) {
        self.state = .game_over;
        self.audio.play(.game_over);
        return;
    }

    self.checkSuccess();
}

fn checkSuccess(self: *Game) void {
    for (self.modules[0..self.module_count]) |*module| {
        module.updateSolved();

        if (!module.solved) {
            return;
        }
    }

    self.state = .success;
    self.audio.play(.success);
    self.timer.running = false;
}

pub fn restart(self: *Game) void {
    self.* = Game.init(self.difficulty, self.random);
}

pub fn moduleCount(self: Game) usize {
    return self.module_count;
}


};
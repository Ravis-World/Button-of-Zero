const Difficulty = @import("difficulty.zig").Difficulty;
const Timer = @import("timer.zig").Timer;
const Audio = @import("audio.zig").Audio;

pub const GameState = enum {
    playing,
    game_over,
    won,
};

pub const Game = struct {
    difficulty: Difficulty,
    timer: Timer,
    audio: Audio,
    state: GameState,

    pub fn init(difficulty: Difficulty) Game {
    return .{
        .difficulty = difficulty,
        .timer = Timer.init(
            difficulty.timerSeconds(),
            difficulty.timerSong(),
        ),
        .audio = .{},
        .state = .playing,
    };
}

    pub fn update(self: *Game, delta_time: f32) void {
        if (self.state != .playing) {
            return;
        }

        self.timer.update(delta_time);

        if (self.timer.isFinished()) {
            self.state = .game_over;
            self.audio.playGameOver();
        }
    }
};
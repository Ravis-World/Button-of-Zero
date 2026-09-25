pub const Music = enum {
    countdown_easy,
    countdown_medium,
    countdown_hard,
    game_over,
    success,
};

pub const Audio = struct {
    current_music: ?Music = null,

    pub fn playCountdown(self: *Audio, song: Music) void {
        self.current_music = song;
    }

    pub fn playGameOver(self: *Audio) void {
        self.current_music = .game_over;
    }

    pub fn playSuccess(self: *Audio) void {
        self.current_music = .success;
    }

    pub fn stop(self: *Audio) void {
        self.current_music = null;
    }
};

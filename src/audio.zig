pub const Music = enum {
countdown_easy,
countdown_medium,
countdown_hard,
game_over,
success,
};

pub const Audio = struct {
current_music: ?Music = null,

pub fn play(self: *Audio, music: Music) void {
    self.current_music = music;
}

pub fn stop(self: *Audio) void {
    self.current_music = null;
}


};
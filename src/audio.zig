const builtin = @import("builtin");
const rl = @import("raylib");

extern "kernel32" fn FindResourceA(module: ?*anyopaque, name: [*:0]const u8, resource_type: [*:0]const u8) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn LoadResource(module: ?*anyopaque, resource: *anyopaque) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn LockResource(resource: *anyopaque) callconv(.winapi) ?[*]const u8;
extern "kernel32" fn SizeofResource(module: ?*anyopaque, resource: *anyopaque) callconv(.winapi) u32;

pub const Music = enum {
    countdown_easy,
    countdown_medium,
    countdown_hard,
    game_over,
    success,
};

pub const Audio = struct {
    current_music: ?Music = null,
    music_easy: ?rl.Music = null,
    music_medium: ?rl.Music = null,
    music_hard: ?rl.Music = null,
    music_game_over: ?rl.Music = null,
    music_success: ?rl.Music = null,

    pub fn init() Audio {
        rl.initAudioDevice();

        if (builtin.os.tag == .windows) {
            return .{
                .music_easy = loadEmbeddedMusic(101),
                .music_medium = loadEmbeddedMusic(102),
                .music_hard = loadEmbeddedMusic(103),
                .music_game_over = loadEmbeddedMusic(104),
                .music_success = loadEmbeddedMusic(105),
            };
        }

        return .{
            .music_easy = loadMusicFile("assets/music/countdown_easy.mp3"),
            .music_medium = loadMusicFile("assets/music/countdown_medium.mp3"),
            .music_hard = loadMusicFile("assets/music/countdown_hard.mp3"),
            .music_game_over = loadMusicFile("assets/music/game_over.mp3"),
            .music_success = loadMusicFile("assets/music/success.mp3"),
        };
    }

    fn loadEmbeddedMusic(resource_id: usize) ?rl.Music {
        const resource = FindResourceA(null, @ptrFromInt(resource_id), @ptrFromInt(10)) orelse return null;
        const size = SizeofResource(null, resource);
        if (size == 0) return null;
        const loaded = LoadResource(null, resource) orelse return null;
        const data = LockResource(loaded) orelse return null;
        return rl.loadMusicStreamFromMemory(".mp3", data[0..size]) catch null;
    }

    fn loadMusicFile(path: [:0]const u8) ?rl.Music {
        if (!rl.fileExists(path)) return null;
        return rl.loadMusicStream(path) catch null;
    }

    pub fn deinit(self: *Audio) void {
        if (self.music_easy) |*m| rl.unloadMusicStream(m.*);
        if (self.music_medium) |*m| rl.unloadMusicStream(m.*);
        if (self.music_hard) |*m| rl.unloadMusicStream(m.*);
        if (self.music_game_over) |*m| rl.unloadMusicStream(m.*);
        if (self.music_success) |*m| rl.unloadMusicStream(m.*);
        rl.closeAudioDevice();
    }

    pub fn play(self: *Audio, music: Music) void {
        self.stop();
        self.current_music = music;
        const target_music = switch (music) {
            .countdown_easy => self.music_easy,
            .countdown_medium => self.music_medium,
            .countdown_hard => self.music_hard,
            .game_over => self.music_game_over,
            .success => self.music_success,
        };

        if (target_music) |m| {
            rl.playMusicStream(m);
        }
    }

    pub fn update(self: *Audio) void {
        if (self.current_music) |music| {
            const target_music = switch (music) {
                .countdown_easy => self.music_easy,
                .countdown_medium => self.music_medium,
                .countdown_hard => self.music_hard,
                .game_over => self.music_game_over,
                .success => self.music_success,
            };

            if (target_music) |m| {
                rl.updateMusicStream(m);
            }
        }
    }

    pub fn stop(self: *Audio) void {
        if (self.current_music) |music| {
            const target_music = switch (music) {
                .countdown_easy => self.music_easy,
                .countdown_medium => self.music_medium,
                .countdown_hard => self.music_hard,
                .game_over => self.music_game_over,
                .success => self.music_success,
            };

            if (target_music) |m| {
                rl.stopMusicStream(m);
            }
        }
        self.current_music = null;
    }
};

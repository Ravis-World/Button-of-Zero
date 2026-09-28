pub const TimerSong = enum {
    easy,
    medium,
    hard,
};

pub const Timer = struct {
    remaining: f32,
    running: bool,
    song: TimerSong,

    pub fn init(duration_seconds: u32, song: TimerSong) Timer {
        return .{
            .remaining = @floatFromInt(duration_seconds),
            .running = true,
            .song = song,
        };
    }

    pub fn update(self: *Timer, delta_time: f32) void {
        if (!self.running) {
            return;
        }

        self.remaining -= delta_time;

        if (self.remaining <= 0) {
            self.remaining = 0;
            self.running = false;
        }
    }

    pub fn isFinished(self: Timer) bool {
        return self.remaining <= 0;
    }

    pub fn seconds(self: Timer) u32 {
        return @intFromFloat(self.remaining);
    }
};

pub const Equation = struct {
    left: i32,
    right: i32,
    result: i32,

    pub fn init(left: i32, right: i32) Equation {
        return .{
            .left = left,
            .right = right,
            .result = left + right,
        };
    }

    pub fn changeLeft(self: *Equation, amount: i32) void {
        self.left += amount;
        self.updateResult();
    }

    pub fn changeRight(self: *Equation, amount: i32) void {
        self.right += amount;
        self.updateResult();
    }

    fn updateResult(self: *Equation) void {
        self.result = self.left + self.right;
    }

    pub fn isSolved(self: Equation) bool {
        return self.result == 0;
    }
};
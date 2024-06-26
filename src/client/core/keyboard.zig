const rl = @import("raylib");

// ====================================================================================================
// Helpers for Raylib keyboard stuffs
// ====================================================================================================

pub fn isValidControl() bool {
    return rl.isKeyDown(.key_caps_lock) or // remaped ctrl to caps
        rl.isKeyDown(.key_left_control) or // L-CTRL
        rl.isKeyDown(.key_right_control); // R-CTRL
}

pub fn isValidShift() bool {
    return rl.isKeyDown(.key_left_shift) or rl.isKeyDown(.key_right_shift);
}

pub fn isValidControlCombination() bool {
    return ((rl.isKeyDown(.key_right_shift) or rl.isKeyDown(.key_left_shift)) and rl.isKeyDown(.key_caps_lock)) or // remaped ctrl to caps + shift
        rl.isKeyDown(.key_left_control) or // L-CTRL
        rl.isKeyDown(.key_right_control); // R-CTRL
}

pub fn isPressedAndOrHeld(key: rl.KeyboardKey) bool {
    return rl.isKeyPressed(key) or rl.isKeyPressedRepeat(key);
}

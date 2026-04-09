# Test Plan (ISTQB-aligned, lightweight)

## 1. Purpose
Establish an extensible automated test foundation for Project Monarch to support fast feedback, CI confidence, and safe iteration.

## 2. Test levels
- **Unit / Component tests (automated):** GDScript logic tests for data and rules (BoardData, Player, etc.)
- **Integration tests (future):** scene wiring, signals between nodes, persistence behavior
- **System / end-to-end (future):** exported APK smoke tests (device/emulator), UI navigation flows

## 3. Scope (initial)
In scope now:
- Board data invariants (tile count, wrap-around lookup)
- Player state transitions (movement wrap, balance updates, emitted signals)

Out of scope (for now):
- Rendering, Android export, input timing, and UI layouts (these will be covered by integration/system tests later)

## 4. Test design techniques
- **Equivalence partitioning:** zero/positive steps for movement; tiles with positive/negative/zero amounts
- **Boundary values:** wrap-around at `tile_count` and `tile_count - 1`
- **State transition testing:** `reset_state → move_player → resolve_tile`

## 5. Automation approach
- Headless runner: `res://tests/test_runner.gd`
- Convention: any `res://tests/test_*.gd` with `run(ctx)` is executed
- CI: run tests on PRs to `main` and on `main` pushes

## 6. Entry / exit criteria
Entry:
- Test files compile and runner discovers them

Exit (pass):
- Runner returns exit code 0
- No failures printed


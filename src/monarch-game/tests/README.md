# GDScript automation tests

This project uses a tiny, dependency-free test runner (no external Godot addons yet) so we can grow automated coverage incrementally.

## Run locally

From the repo root:

```sh
godot --headless --path src/monarch-game --script res://tests/test_runner.gd
```

## Add a new test

- Create a new file `src/monarch-game/tests/test_<topic>.gd`
- It must:
  - `extends RefCounted`
  - implement `func run(ctx) -> void:`
- Use the `ctx.assert_*` helpers from `test_context.gd`


# Beat Up — Unit + E2E tests

## Layout
- tests/framework/     assert + suite base
- tests/unit/          pure logic (CityMath, CarMath)
- tests/e2e/           full city + car scene checks
- tests/run_all.gd     headless entrypoint
- scenes/test_runner.tscn  editor entrypoint (F6)
- scenes/test_physics.tscn interactive physics harness

## Run in Godot Editor
1. Open `scenes/test_runner.tscn`
2. Press F6 (Run Current Scene)
3. Read Output dock for PASS/FAIL

Interactive physics probe (manual drive + auto checks):
1. Open `scenes/test_physics.tscn`
2. Press F6
3. Press T to re-run checks

## Run headless (CI / terminal)
godot --headless --path . -s res://tests/run_all.gd

Exit code 0 = all passed, 1 = failures.

## What is covered
Unit:
- street/intersection layout math
- spawn cell
- bounds clamp
- car speed / facing / velocity helpers

E2E:
- spawn on road
- WorldCollision shapes present
- car collision layers
- building collision resistance
- out-of-bounds clamp
- stays on road after driving

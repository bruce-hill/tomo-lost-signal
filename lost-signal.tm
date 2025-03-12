#!/bin/env tomo

# Lost Signal is a game for a Recurse Center game jam

use ./raylib.tm
use ./world.tm
use ./player.tm

DEFAULT_LEVELS := [
    (./levels/level1.map),
    (./levels/level2.map),
    (./levels/level3.map),
    (./levels/level4.map),
    (./levels/level5.map),
    (./levels/level6.map),

    (./levels/victory.map),
]

func main(levels=DEFAULT_LEVELS):
    if levels.length == 0:
        exit("No levels provided!")

    inline C {
        InitWindow(GetScreenWidth(), GetScreenHeight(), "raylib [core] example - 2d camera");
        ToggleFullscreen();
    }

    level_index := 1
    world := World.from_map(levels[level_index])

    SetTargetFPS(60)

    while not WindowShouldClose():
        dt := GetFrameTime()
        world:update(dt)

        if world.won_time and level_index < levels.length:
            if GetTime() > world.won_time + 3.0:
                level_index += 1
                world = World.from_map(levels[level_index])

        if inline C : Bool { IsKeyPressed(KEY_R) }:
            world = World.from_map(levels[level_index])
        else if inline C : Bool { IsKeyPressed(KEY_N) } and level_index < levels.length:
            level_index += 1
            world = World.from_map(levels[level_index])
        else if inline C : Bool { IsKeyPressed(KEY_P) } and level_index > 1:
            level_index -= 1
            world = World.from_map(levels[level_index])

        BeginDrawing()
        ClearBackground(Color(0,0,0))
        world:draw()
        EndDrawing()

    CloseWindow()


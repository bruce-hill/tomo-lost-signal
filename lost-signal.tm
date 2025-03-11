#!/sbin/tomo
use libraylib.so
use <raylib.h>
use <raymath.h>

use ./camera.tm
use ./world.tm
use ./player.tm

DEFAULT_LEVELS := [
    (./levels/level1.map),
    (./levels/level2.map),
    (./levels/level3.map),
    (./levels/level4.map),
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

    extern SetTargetFPS:func(fps:Int32)
    SetTargetFPS(60)

    extern WindowShouldClose:func(->Bool)

    while not WindowShouldClose():
        extern GetFrameTime:func(->Num32)
        dt := GetFrameTime()
        world:update(dt)

        if inline C : Bool { IsKeyPressed(KEY_R) }:
            world = World.from_map(levels[level_index])
        else if inline C : Bool { IsKeyPressed(KEY_N) } and level_index < levels.length:
            level_index += 1
            world = World.from_map(levels[level_index])
        else if inline C : Bool { IsKeyPressed(KEY_P) } and level_index > 1:
            level_index -= 1
            world = World.from_map(levels[level_index])

        extern BeginDrawing:func()
        extern EndDrawing:func()
        do:
            BeginDrawing()
            defer: EndDrawing()

            inline C {
                ClearBackground((Color){0x00, 0x00, 0x00, 0xFF});
            }

            world:draw()

    extern CloseWindow:func()
    CloseWindow()


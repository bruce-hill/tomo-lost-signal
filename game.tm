use libraylib.so
use <raylib.h>
use <raymath.h>

use ./camera.tm
use ./world.tm
use ./player.tm

func main(map=(./map.txt)):
    inline C {
        InitWindow(GetScreenWidth(), GetScreenHeight(), "raylib [core] example - 2d camera");
        ToggleFullscreen();
    }

    map_contents := map:read() or exit("Could not find the game map: $map")

    world := @World()
    world:load_map(map_contents)

    extern SetTargetFPS:func(fps:Int32)
    SetTargetFPS(60)

    extern WindowShouldClose:func(->Bool)

    world.camera.zoom = inline C : Num32 {
        (float)GetScreenWidth()/1200.
    }

    while not WindowShouldClose():
        extern GetFrameTime:func(->Num32)
        dt := GetFrameTime()
        world:update(dt)

        extern BeginDrawing:func()
        extern EndDrawing:func()
        do:
            BeginDrawing()
            defer: EndDrawing()

            inline C {
                ClearBackground((Color){0xCC, 0xCC, 0xCC, 0xFF});
            }

            world:draw()

    extern CloseWindow:func()
    CloseWindow()


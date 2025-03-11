use libraylib.so
use <raylib.h>
use <raymath.h>

use ./camera.tm
use ./world.tm
use ./player.tm

func is_pressed(key:Text -> Bool):
    return inline C : Bool {
        IsKeyPressed(Text$get_grapheme(_$key, 0))
    }

func main(map=(./map.txt)):
    inline C {
        InitWindow(GetScreenWidth(), GetScreenHeight(), "raylib [core] example - 2d camera");
        ToggleFullscreen();
    }

    world := World.from_map(map)

    extern SetTargetFPS:func(fps:Int32)
    SetTargetFPS(60)

    extern WindowShouldClose:func(->Bool)

    while not WindowShouldClose():
        extern GetFrameTime:func(->Num32)
        dt := GetFrameTime()
        world:update(dt)

        if is_pressed("R"):
            world = World.from_map(map)

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


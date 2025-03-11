# Raylib wrappers for some functions and structs

use libraylib.so
use <raylib.h>
use <raymath.h>

struct Color(r,g,b:Byte,a=Byte(255); extern)

struct Rectangle(x,y,width,height:Num32; extern):
    func draw(r:Rectangle, color:Color):
        DrawRectangleRec(r, color)

struct Camera2D(offset:Vector2, target:Vector2, rotation=Num32(0), zoom=Num32(1); extern)

struct Texture(id,width,height,mipmaps,format:Int32):
    func load(path:Path -> Texture; cached):
        c_string := CString(path)
        result := Texture(0,0,0,0,0)
        inline C {
            Texture2D tex = LoadTexture(_$c_string);
            memcpy(&_$result, &tex, sizeof(tex));
        }
        return result

    func draw(t:Texture, pos,size:Vector2, angle=Num32(0.0), tint=Color(0xFF,0xFF,0xFF)):
        inline C {
            DrawTexturePro(
                *(Texture2D*)&_$t,
                (Rectangle){0,0,_$t.width,_$t.height},
                (Rectangle){_$pos.x,_$pos.y,_$size.x,_$size.y},
                (Vector2){_$size.x/2,_$size.y/2},
                _$angle*180./M_PI,
                *(Color*)&_$tint);
        }

struct Vector2(x,y:Num32; extern):
    ZERO := Vector2(0, 0)
    func plus(a,b:Vector2->Vector2; inline):
        return Vector2(a.x+b.x, a.y+b.y)
    func minus(a,b:Vector2->Vector2; inline):
        return Vector2(a.x-b.x, a.y-b.y)
    func times(a,b:Vector2->Vector2; inline):
        return Vector2(a.x*b.x, a.y*b.y)
    func negative(v:Vector2->Vector2; inline):
        return Vector2(-v.x, -v.y)
    func dot(a,b:Vector2->Num32; inline):
        return ((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y))!
    func cross(a,b:Vector2->Num32; inline):
        return a.x*b.y - a.y*b.x
    func scaled_by(v:Vector2, k:Num32->Vector2; inline):
        return Vector2(v.x*k, v.y*k)
    func divided_by(v:Vector2, divisor:Num32->Vector2; inline):
        return Vector2(v.x/divisor, v.y/divisor)
    func length(v:Vector2->Num32; inline):
        return (v.x*v.x + v.y*v.y)!:sqrt()
    func dist(a,b:Vector2->Num32; inline):
        return a:minus(b):length()
    func angle(v:Vector2->Num32; inline):
        return Num32.atan2(v.y, v.x)
    func norm(v:Vector2->Vector2; inline):
        if v.x == 0 and v.y == 0:
            return v
        len := v:length()
        return Vector2(v.x/len, v.y/len)
    func rotated(v:Vector2, radians:Num32 -> Vector2):
        cos := radians:cos() or return v
        sin := radians:sin() or return v
        return Vector2(cos*v.x - sin*v.y, sin*v.x + cos*v.y)
    func mix(a,b:Vector2, amount:Num32 -> Vector2):
        return Vector2(
            amount:mix(a.x, b.x),
            amount:mix(a.y, b.y),
        )

extern BeginDrawing:func()
extern BeginMode2D:func(camera:Camera2D)
extern ClearBackground:func(color:Color)
extern CloseWindow:func()
extern DrawCircleV:func(pos:Vector2, radius:Num32, color:Color)
extern DrawRectangle:func(x,y,width,height:Int32, color:Color)
extern DrawRectangleRec:func(rec:Rectangle, color:Color)
extern DrawRectangleV:func(pos:Vector2, size:Vector2, color:Color)
extern DrawText:func(text:CString, x,y:Int32, text_height:Int32, color:Color)
extern EndDrawing:func()
extern EndMode2D:func()
extern GetFrameTime:func(->Num32)
extern GetScreenHeight:func(->Int32)
extern GetScreenWidth:func(->Int32)
extern InitWindow:func(width:Int32, height:Int32, title:CString)
extern SetTargetFPS:func(fps:Int32)
extern WindowShouldClose:func(->Bool)
extern MeasureText:func(text:CString, font_size:Int32 -> Int32)
extern DrawText:func(text:CString, x:Int32, y:Int32, font_size:Int32, color:Color)

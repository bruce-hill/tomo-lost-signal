use <raylib.h>

use ./color.tm

struct Texture(id,width,height,mipmaps,format:Int32):
    func load(path:Path -> Texture; cached):
        c_string := CString(path)
        result := Texture(0,0,0,0,0)
        inline C {
            Texture2D tex = LoadTexture(_$c_string);
            memcpy(&_$result, &tex, sizeof(tex));
        }
        return result

    func draw(t:Texture, pos,size:Vec2, angle=Num32(0.0), tint=Color.WHITE):
        inline C {
            DrawTexturePro(
                *(Texture2D*)&_$t,
                (Rectangle){0,0,_$t.$width,_$t.$height},
                (Rectangle){_$pos.$x,_$pos.$y,_$size.$x,_$size.$y},
                (Vector2){_$size.$x/2,_$size.$y/2},
                _$angle*180./M_PI,
                *(Color*)&_$tint);
        }

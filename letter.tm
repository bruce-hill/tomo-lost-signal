use <raylib.h>
use ./vec32.tm
use ./color.tm

struct Letter(string:CString, pos:Vec2, color=Color.rgb(1.,1.,1.,.7), size=Int32(40)):
    func draw(l:Letter):
        inline C {
            DrawText(_$l.$string, (int)_$l.$pos.$x, (int)_$l.$pos.$y, _$l.$size, *(Color*)&_$l.$color);
        }

use <raylib.h>
use ./vec32.tm
use ./color.tm

struct Letter(string:CString, pos:Vec2, color=Color.rgb(1.,1.,.4,.8), size=Int32(30)):
    func draw(l:Letter):
        inline C {
            int w = MeasureText(_$l.$string, _$l.$size);
            DrawText(_$l.$string, (int)_$l.$pos.$x - w/2, (int)_$l.$pos.$y, _$l.$size, *(Color*)&_$l.$color);
        }

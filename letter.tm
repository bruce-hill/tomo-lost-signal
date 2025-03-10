use vectors
use ./color.tm

struct Letter(string:CString, pos:Vec2, color=Color(0,0,0,.7), size=Int32(40)):
    func draw(l:Letter):
        inline C {
            DrawText(_$l.$string, (int)_$l.$pos.$x, (int)_$l.$pos.$y, _$l.$size,
                (Color){
                    (uint8_t)(255.*_$l.$color.$r),
                    (uint8_t)(255.*_$l.$color.$g),
                    (uint8_t)(255.*_$l.$color.$b),
                    (uint8_t)(255.*_$l.$color.$a),
                }
            );
        }

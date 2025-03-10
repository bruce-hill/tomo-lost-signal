# Defines a struct used to represent colors using 64-bit floats (0.0 - 1.0),
# which can be used to draw colored rectangles in raylib
use <raylib.h>
use ./vec32.tm

struct Color(r,g,b:Byte,a=Byte(255)):
    func rgb(r,g,b:Num,a=1.0 -> Color):
        return Color(
            inline C : Byte { (Byte_t)(255.0*_$r) },
            inline C : Byte { (Byte_t)(255.0*_$g) },
            inline C : Byte { (Byte_t)(255.0*_$b) },
            inline C : Byte { (Byte_t)(255.0*_$a) },
        )

    PLAYER := Color.rgb(.1,.1,.6,1.)
    WHITE := Color.rgb(1.,1.,1.,1.)
    BLACK := Color.rgb(0.,0.,0.,1.)
    GRAY := Color.rgb(.4,.4,.4)
    LIGHT_GRAY := Color.rgb(.7,.7,.7)
    GOAL := Color.rgb(.1,.5,.0)

    func draw_rectangle(c:Color, pos:Vec2, size:Vec2):
        inline C {
            DrawRectangle((int)_$pos.$x, (int)_$pos.$y, (int)_$size.$x, (int)_$size.$y, *(Color*)&_$c);
        }

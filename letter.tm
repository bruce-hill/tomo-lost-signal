# An object that represents a letter of text on the map

use ./raylib.tm

struct Letter(string:CString, pos:Vector2, color=Color(0xff,0xff,0x66,0xcc), size=Int32(30)):
    func draw(l:Letter):
        w := MeasureText(l.string, l.size)
        DrawText(l.string, Int32(l.pos.x, yes) - w/2, Int32(l.pos.y, yes), l.size, l.color)

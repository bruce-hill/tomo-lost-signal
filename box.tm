# Defines a struct representing boxes on the terrain
use vectors

use ./color.tm

struct Box(pos:Vec2, size=Vec2(50, 50), color=Color.GRAY):
    func draw(b:Box):
        b.color:draw_rectangle(b.pos-b.size/2, b.size)

    func offset_by(b:Box, offset:Vec2 -> Box):
        return Box(b.pos + offset, b.size, b.color)

    func at(b:Box, pos:Vec2 -> Box):
        b.pos = pos
        return b

    func has_point(b:Box, point:Vec2 -> Bool):
        return ((b.pos.x - b.size.x/2 <= point.x and point.x <= b.pos.x + b.size.x/2) and
                (b.pos.y - b.size.y/2 <= point.y and point.y <= b.pos.y + b.size.y/2))

    func clamped(b:Box, point:Vec2 -> Vec2):
        return Vec2(
            point.x:clamped(b.pos.x - b.size.x/2, b.pos.x + b.size.x/2),
            point.y:clamped(b.pos.y - b.size.y/2, b.pos.y + b.size.y/2))

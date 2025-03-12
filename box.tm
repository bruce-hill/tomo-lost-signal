# Defines a struct representing boxes on the terrain

use ./raylib.tm

struct Box(pos:Vector2, size=Vector2(50, 50), color=Color(0x51,0x51,0x72)):
    func draw(b:Box):
        DrawRectangleV(b.pos - b.size/2, b.size, b.color)

    func offset_by(b:Box, offset:Vector2 -> Box):
        return Box(b.pos + offset, b.size, b.color)

    func at(b:Box, pos:Vector2 -> Box):
        b.pos = pos
        return b

    func has_point(b:Box, point:Vector2, epsilon=Num32(0.1) -> Bool):
        return ((b.pos.x - b.size.x/2 <= point.x + epsilon and point.x - epsilon <= b.pos.x + b.size.x/2) and
                (b.pos.y - b.size.y/2 <= point.y + epsilon and point.y - epsilon <= b.pos.y + b.size.y/2))

    func clamped(b:Box, point:Vector2 -> Vector2):
        return Vector2(
            point.x:clamped(b.pos.x - b.size.x/2, b.pos.x + b.size.x/2),
            point.y:clamped(b.pos.y - b.size.y/2, b.pos.y + b.size.y/2))

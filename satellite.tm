# A satellite sits on the map and beams controls to the player

use ./raylib.tm
use ./box.tm
use ./player.tm

struct Satellite(pos:Vector2, beam_end=Vector2(0,0), facing=Vector2(1,0)):
    SIZE := Vector2(32,32)

    func draw_beam(s:Satellite):
        DrawLineEx(s.pos, s.beam_end, 5, Color(0x80,0x80,0xff,0xcc))

    func draw(s:Satellite):
        texture := Texture.load((./assets/Satellite.png))
        texture:draw(s.pos, Satellite.SIZE, angle=s.facing:angle() + Num32.TAU/8)

    func update(s:&Satellite, boxes:[@Box], player:&Player):
        s.facing = (player.pos - s.pos):norm()
        s.beam_end = s:raycast(boxes, player.pos)
        if s.beam_end:dist(player.pos):near(0):
            player.has_signal = yes

    func raycast(s:Satellite, boxes:[@Box], end:Vector2, epsilon=Num32(0.1) -> Vector2):
        return end if s.pos == end
        dist := s.pos:dist(end)
        forward := (end - s.pos)

        for b in boxes:
            x_min := b.pos.x - b.size.x/2
            x_max := b.pos.x + b.size.x/2
            y_min := b.pos.y - b.size.y/2
            y_max := b.pos.y + b.size.y/2

            times := [
                (x_min - s.pos.x)/forward.x,
                (x_max - s.pos.x)/forward.x,
                (y_min - s.pos.y)/forward.y,
                (y_max - s.pos.y)/forward.y,
            ]
            hit_time := (_min_: t for t in times if (0 <= t + epsilon and t + epsilon <= 1) and b:has_point(s.pos + (t or skip)*forward, epsilon=epsilon))
            if hit_time:
                return s.pos + hit_time*forward

        return end

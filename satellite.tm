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

    func vertical_edge_hit(pos,dir:Vector2, edge_x:Num32, y_min,y_max:Num32 -> Vector2?):
        t := (edge_x - pos.x)/dir.x or return none
        return none if t < 0
        y := pos.y + (t*dir.y)!
        return none if y < y_min or y > y_max
        return Vector2(edge_x, y)

    func horizontal_edge_hit(pos,dir:Vector2, edge_y:Num32, x_min,x_max:Num32 -> Vector2?):
        t := (edge_y - pos.y)/dir.y or return none
        return none if t < 0
        x := pos.x + (t*dir.x)!
        return none if x < x_min or x > x_max
        return Vector2(x, edge_y)

    func raycast(s:Satellite, boxes:[@Box], end:Vector2, epsilon=Num32(0.1) -> Vector2):
        return end if s.pos == end
        dist := s.pos:dist(end)
        forward := (end - s.pos):norm()

        for b in boxes:
            skip if b.color.a < 0xff
            x_min := b.pos.x - b.size.x/2
            x_max := b.pos.x + b.size.x/2
            y_min := b.pos.y - b.size.y/2
            y_max := b.pos.y + b.size.y/2
            hit := none:Vector2
            if forward.y != 0:
                hit = Satellite.horizontal_edge_hit(s.pos, forward, y_min, x_min, x_max)
                if hit: end = end _min_:dist(s.pos) hit
                hit = Satellite.horizontal_edge_hit(s.pos, forward, y_max, x_min, x_max)
                if hit: end = end _min_:dist(s.pos) hit
            if forward.x != 0:
                hit = Satellite.vertical_edge_hit(s.pos, forward, x_min, y_min, y_max)
                if hit: end = end _min_:dist(s.pos) hit
                hit = Satellite.vertical_edge_hit(s.pos, forward, x_max, y_min, y_max)
                if hit: end = end _min_:dist(s.pos) hit

        return end

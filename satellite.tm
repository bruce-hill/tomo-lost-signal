# A satellite sits on the map and beams controls to the player

use ./raylib.tm

struct Satellite(pos:Vector2, facing=Vector2(1,0)):
    SIZE := Vector2(32,32)
    func draw(s:Satellite):
        texture := Texture.load((./assets/Satellite.png))
        texture:draw(s.pos, Satellite.SIZE, angle=s.facing:angle() + Num32.TAU/8)

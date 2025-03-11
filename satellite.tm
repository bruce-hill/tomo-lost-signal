
use ./color.tm
use ./vec32.tm
use ./textures.tm

struct Satellite(pos:Vec2, facing=Vec2(1,0)):
    SIZE := Vec2(32,32)
    func draw(s:Satellite):
        texture := Texture.load((./assets/Satellite.png))
        texture:draw(s.pos, Satellite.SIZE, angle=s.facing:angle() + Num32.TAU/8)

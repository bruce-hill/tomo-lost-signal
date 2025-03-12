# Defines a struct representing the player, which is controlled by WASD keys

use ./raylib.tm
use ./world.tm

struct Player(
    pos,prev_pos:Vector2,
    facing=Vector2(1,0),
    has_signal=no,
    dead=no,
    target_vel=Vector2(0,0),
    texture=Texture.load((./assets/RocketWhite.png)),
):
    WALK_SPEED := Num32(500.)
    ACCEL := Num32(0.1)
    SIZE := Vector2(32, 32)
    TEXTURE := none:Texture

    func update(p:@Player):
        return if p.dead

        vel := (p.pos - p.prev_pos)/World.DT
        vel = vel:mix(p.target_vel, Player.ACCEL)

        p.prev_pos, p.pos = p.pos, p.pos + World.DT*vel
        if not p.pos:dist(p.prev_pos):near(0, .1, .1):
            p.facing = p.facing:mix((p.pos-p.prev_pos):norm(), .1)

    func draw(p:Player):
        return if p.dead
        angle := p.facing:angle()
        tint := if p.has_signal:
            Color(0xff,0xff,0xff)
        else:
            Color(0xcc,0x66,0x66)
        p.texture:draw(p.pos, Player.SIZE, angle=angle+Num32.TAU/4, tint=tint)
        if not p.has_signal:
            DrawText(CString("???"), Int32(p.pos.x,yes) - 24, Int32(p.pos.y,yes) - 40, 24, Color(0xff,0xff,0xff,0xa0))

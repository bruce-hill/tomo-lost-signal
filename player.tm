# Defines a struct representing the player, which is controlled by WASD keys
use libraylib.so
use <raylib.h>
use <raymath.h>

use ./textures.tm
use ./vec32.tm
use ./world.tm

struct Player(pos,prev_pos:Vec2, facing=Vec2(1,0), has_signal=no, target_vel=Vec2(0,0), texture=Texture.load((./assets/RocketWhite.png))):
    WALK_SPEED := Num32(500.)
    ACCEL := Num32(0.3)
    FRICTION := Num32(0.99)
    SIZE := Vec2(30, 30)
    TEXTURE := none:Texture

    func update(p:@Player):
        if p.has_signal:
            target_x := inline C:Num32 {
                (Num32_t)((IsKeyDown(KEY_A) ? -1 : 0) + (IsKeyDown(KEY_D) ? 1 : 0))
            }
            target_y := inline C:Num32 {
                (Num32_t)((IsKeyDown(KEY_W) ? -1 : 0) + (IsKeyDown(KEY_S) ? 1 : 0))
            }
            p.target_vel = Vec2(target_x, target_y):norm() * Player.WALK_SPEED

        vel := (p.pos - p.prev_pos)/World.DT
        vel *= Player.FRICTION
        vel = vel:mix(p.target_vel, Player.ACCEL)

        p.prev_pos, p.pos = p.pos, p.pos + World.DT*vel
        if p.pos != p.prev_pos:
            p.facing = p.facing:mix((p.pos-p.prev_pos):norm(), .1)

    func draw(p:Player):
        angle := p.facing:angle()
        Color.PLAYER:draw_rectangle(p.pos-Player.SIZE/2, Player.SIZE)
        p.texture:draw(p.pos, Player.SIZE, angle=angle+Num32.TAU/4)

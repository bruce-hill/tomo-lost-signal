use libraylib.so
use <raylib.h>
use <raymath.h>
use vectors

struct Camera(pos=Vec2(0,0), target=Vec2(0, 0), facing=Vec2(1,0), anchor=Vec2(0.5, 0.5), rotation=0.0, zoom=1.0, shake=0.0):
    func begin_drawing(c:Camera):
        pos := c.pos
        if c.shake > 1.0:
            pos += Vec2(c.shake, 0):rotated(random:num(0, Num.TAU))

        inline C {
            Camera2D cam = {
                .target={(float)_$pos.$x, (float)_$pos.$y},
                .offset={(float)(_$c.$anchor.$x * GetScreenWidth()), (float)(_$c.$anchor.$y * GetScreenHeight())},
                .rotation=(float)_$c.$rotation,
                .zoom=(float)_$c.$zoom,
            };
            BeginMode2D(cam);
        }

    func draw(c:Camera):
        forward := c.pos + 50*c.facing
        inline C {
            DrawCircleV((Vector2){(float)_$c.$pos.$x, (float)_$c.$pos.$y}, 10, (Color){255,128,128,255});
            DrawLineEx((Vector2){(float)_$c.$pos.$x, (float)_$c.$pos.$y},
                       (Vector2){(float)_$forward.$x, (float)_$forward.$y},
                       5,
                       (Color){255,128,128,255});
        }

    func end_drawing(c:Camera):
        inline C {
            EndMode2D();
        }

    func update(c:&Camera, dt:Num):
        c.pos = c.pos:mix(c.target, 0.1)
        c.shake -= dt*2.0

    func add_shake(c:&Camera, amount:Num):
        c.shake = (c.shake:exp() + amount):log() or 0.

    func follow(c:&Camera, pos:Vec2):
        dist := c.target:dist(pos)
        toward_cam := (c.target - pos):norm()
        toward_player := (pos - c.target):norm()
        if toward_player:dot(c.facing) < 0: # If behind the camera
            if toward_cam:dot(pos - c.target) < -100:
                c.facing = toward_player
                c.target = pos - 50*c.facing
            else if toward_cam:dot(pos - c.target) < -50:
                c.target = pos - 50*toward_cam
                c.facing = -toward_player
        else:
            if dist > 100.:
                c.target = pos + 100.*toward_cam
                c.facing = toward_player

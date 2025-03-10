use libraylib.so
use <raylib.h>
use <raymath.h>
use ./vec32.tm
use ./box.tm

func _draw_circle(center:Vec2, radius=10.0, color=Color.rgb(1,0,0,1)):
    inline C {
        DrawCircleV(*(Vector2*)&_$center, (int)10, *(Color*)&_$color);
    }

struct Camera(pos=Vec2(0,0), target=Vec2(0, 0), forward=Vec2(1,0), anchor=Vec2(0.5, 0.5), rotation=Num32(0.0), zoom=Num32(1.0), shake=Num32(0.0)):
    func begin_drawing(c:Camera):
        pos := c.pos
        if c.shake > Num32(1.0):
            pos += Vec2(c.shake, 0):rotated(random:num32(0, Num32.TAU))

        inline C {
            Camera2D cam = {
                .target=*(Vector2*)&_$pos,
                .offset={_$c.$anchor.$x * (float)GetScreenWidth(), _$c.$anchor.$y * (float)GetScreenHeight()},
                .rotation=_$c.$rotation,
                .zoom=_$c.$zoom,
            };
            BeginMode2D(cam);
        }

    func draw(c:Camera):
        _draw_circle(c.target)
        len := (Num32(50.)*(Num32(1.) _min_ c.forward:length()))!
        _draw_circle(c.target + len*c.forward:norm(), color=Color.rgb(1.,1.,0.,.5))

    func end_drawing(c:Camera):
        inline C {
            EndMode2D();
        }

    func update(c:&Camera, dt:Num32):
        len := (Num32(50.)*(Num32(1.) _min_ c.forward:length()))!
        c.pos = c.pos:mix(c.target + len*c.forward:norm(), 0.9)
        c.shake -= dt*Num32(2.0)

    func add_shake(c:&Camera, amount:Num32):
        c.shake = (c.shake:exp() + amount):log() or Num32(0)

    func follow(c:&Camera, pos:Vec2):
        if not pos:dist(c.target):near(0, 1e-2, 1e-2):
            c.forward = c.forward:mix((pos - c.target):norm(), .05)
            c.target = pos

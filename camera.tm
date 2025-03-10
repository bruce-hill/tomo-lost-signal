use libraylib.so
use <raylib.h>
use <raymath.h>
use vectors
use ./box.tm

func _draw_circle(center:Vec2, radius=10.0, color=Color(1,0,0,1)):
    inline C {
        DrawCircleV((Vector2){(float)_$center.$x, (float)_$center.$y}, (int)10, (Color){(uint8_t)(_$color.$r*255),(uint8_t)(_$color.$g*255),(uint8_t)(_$color.$b*255),(uint8_t)(_$color.$a*255)});
    }

struct Camera(pos=Vec2(0,0), target=Vec2(0, 0), forward=Vec2(1,0), anchor=Vec2(0.5, 0.5), rotation=0.0, zoom=1.0, shake=0.0):
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
        _draw_circle(c.target)
        len := 50.*(1. _min_ c.forward:length())
        _draw_circle(c.target + len*c.forward:norm(), color=Color(1,1,0,.5))

    func end_drawing(c:Camera):
        inline C {
            EndMode2D();
        }

    func update(c:&Camera, dt:Num):
        len := 50.*(1. _min_ c.forward:length())
        c.pos = c.pos:mix(c.target + len*c.forward:norm(), 0.9)
        c.shake -= dt*2.0

    func add_shake(c:&Camera, amount:Num):
        c.shake = (c.shake:exp() + amount):log() or 0.

    func follow(c:&Camera, pos:Vec2):
        if not pos:dist(c.target):near(0, 1e-2, 1e-2):
            c.forward = c.forward:mix((pos - c.target):norm(), .05)
            c.target = pos

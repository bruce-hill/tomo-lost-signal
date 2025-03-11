# A camera module
use ./raylib.tm

struct Camera(pos=Vector2(0,0), target=Vector2(0, 0), forward=Vector2(1,0), anchor=Vector2(0.5, 0.5), rotation=Num32(0.0), zoom=Num32(1.0), shake=Num32(0.0)):
    func begin_drawing(c:Camera):
        pos := c.pos
        if c.shake > Num32(1.0):
            pos += Vector2(c.shake, 0):rotated(random:num32(0, Num32.TAU))

        BeginMode2D(Camera2D(
            target=c.pos,
            offset=Vector2(c.anchor.x * Num32(GetScreenWidth()), c.anchor.y * Num32(GetScreenHeight())),
            rotation=c.rotation,
            zoom=c.zoom,
        ))

    func draw(c:Camera):
        DrawCircleV(c.target, 10, Color(0xff,0,0))
        len := (Num32(50.)*(Num32(1.) _min_ c.forward:length()))!
        DrawCircleV(c.target + len*c.forward:norm(), 10, Color(0xff,0xff,0,0x80))

    func end_drawing(c:Camera):
        EndMode2D()

    func update(c:&Camera, dt:Num32):
        len := (Num32(50.)*(Num32(1.) _min_ c.forward:length()))!
        c.pos = c.pos:mix(c.target + len*c.forward:norm(), 0.9)
        c.shake -= dt*Num32(2.0)

    func add_shake(c:&Camera, amount:Num32):
        c.shake = (c.shake:exp() + amount):log() or Num32(0)

    func follow(c:&Camera, pos:Vector2):
        if not pos:dist(c.target):near(0, 1e-2, 1e-2):
            c.forward = c.forward:mix((pos - c.target):norm(), .05)
            c.target = pos

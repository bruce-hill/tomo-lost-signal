# This file defines a World struct that keeps track of everything

use ./raylib.tm
use ./player.tm
use ./camera.tm
use ./box.tm
use ./letter.tm
use ./satellite.tm

struct Goal(pos:Vector2):
    SIZE := Vector2(32,32)
    func draw(g:Goal):
        texture := Texture.load((./assets/Hurricane.png))
        texture:draw(g.pos, Goal.SIZE)

struct Stars(pos:Vector2, texture:Texture):
    SIZE := Vector2(50,50)
    func draw(s:Stars):
        s.texture:draw(s.pos, Stars.SIZE, tint=Color(0xff,0xff,0xff,0x33))

# Return a displacement relative to `a` that will push it out of `b`
func solve_overlap(a_pos:Vector2, a_size:Vector2, b_pos:Vector2, b_size:Vector2 -> Vector2):
    a_left := a_pos.x - a_size.x/2
    a_right := a_pos.x + a_size.x/2
    a_top := a_pos.y - a_size.x/2
    a_bottom := a_pos.y + a_size.y/2

    b_left := b_pos.x - b_size.x/2
    b_right := b_pos.x + b_size.x/2
    b_top := b_pos.y - b_size.y/2
    b_bottom := b_pos.y + b_size.y/2

    # Calculate the overlap in each dimension
    overlap_x := (a_right _min_ b_right) - (a_left _max_ b_left)
    overlap_y := (a_bottom _min_ b_bottom) - (a_top _max_ b_top)

    # If either axis is not overlapping, then there is no collision:
    if overlap_x <= 0 or overlap_y <= 0:
        return Vector2(0, 0)

    if overlap_x < overlap_y:
        if a_right > b_left and a_right < b_right:
            return Vector2(-(overlap_x), 0)
        else if a_left < b_right and a_left > b_left:
            return Vector2(overlap_x, 0)
    else:
        if a_top < b_bottom and a_top > b_top:
            return Vector2(0, overlap_y)
        else if a_bottom > b_top and a_bottom < b_bottom:
            return Vector2(0, -overlap_y)

    return Vector2(0, 0)

func overlaps(a_pos:Vector2, a_size:Vector2, b_pos:Vector2, b_size:Vector2 -> Bool):
    return solve_overlap(a_pos, a_size, b_pos, b_size) != Vector2(0, 0)

struct World(
    player=@Player(Vector2(0,0), Vector2(0,0)),
    camera=@Camera(Vector2(0,0)),
    goal=Goal(Vector2(0,0)),
    stars=@[:Stars],
    satellites=@[:@Satellite],
    boxes=@[:@Box],
    letters=@[:Letter],
    dt_accum=Num32(0.0),
    won=no,
):
    DT := (Num32(1.)/Num32(60.))!
    STIFFNESS := Num32(0.3)

    func from_map(path:Path -> @World):
        world := @World() 
        world:load_map(path:read() or exit("Could not find the game map: $path"))
        world.camera.zoom = inline C : Num32 {
            (float)GetScreenWidth()/1000.
        }
        return world

    func update(w:@World, dt:Num32):
        w.dt_accum += dt
        while w.dt_accum > 0:
            w:update_once()
            w.dt_accum -= World.DT
        w.camera:follow(w.player.pos)
        w.camera:update(dt)

    func update_once(w:@World):
        if w.player.pos:dist(w.goal.pos) < 50:
            w.player.target_vel = Vector2(0,0)
            w.player.pos = w.player.pos:mix(w.goal.pos, .03)
            w.player.facing = w.player.facing:norm():rotated(Num32.TAU/60)
        else if w.player.has_signal:
            target_x := inline C:Num32 {
                (Num32_t)((IsKeyDown(KEY_A) ? -1 : 0) + (IsKeyDown(KEY_D) ? 1 : 0))
            }
            target_y := inline C:Num32 {
                (Num32_t)((IsKeyDown(KEY_W) ? -1 : 0) + (IsKeyDown(KEY_S) ? 1 : 0))
            }
            w.player.target_vel = Vector2(target_x, target_y):norm() * Player.WALK_SPEED

        w.player:update()

        w.player.has_signal = no
        for s in w.satellites:
            s:update(w.boxes, w.player)

        if overlaps(w.player.pos, Player.SIZE, w.goal.pos, Goal.SIZE):
            w.won = yes

        # Resolve player overlapping with any boxes:
        for i in 3:
            for b in w.boxes:
                correction := solve_overlap(w.player.pos, Player.SIZE, b.pos, b.size)
                #w.camera:add_shake(.1*correction:length())
                w.player.pos += World.STIFFNESS * correction

        w.camera:update(World.DT)

    func draw(w:@World):
        do:
            w.camera:begin_drawing()
            defer: w.camera:end_drawing()

            for s in w.stars:
                s:draw()

            for l in w.letters:
                l:draw()

            for s in w.satellites:
                s:draw_beam()

            for b in w.boxes:
                b:draw()

            for s in w.satellites:
                s:draw()

            w.goal:draw()
            w.player:draw()

            #w.camera:draw()

        if w.won:
            inline C {
                DrawText("WINNER", GetScreenWidth()/2-48*3, GetScreenHeight()/2-24, 48, (Color){0x80,0xFF,0x80,0xFF});
            }

    func load_map(w:@World, map:Text):
        map = map:replace($/  /, "* ")
        w.boxes = @[:@Box]
        box_size := Vector2(50., 50.)
        star_textures := [Texture.load(t) for t in (./assets/WhiteStar*):glob()]
        for y,line in map:lines():
            for x,cell in line:split():
                pos := Vector2((Num32(x)-1) * box_size.x/2, (Num32(y)-1) * box_size.y)
                if cell == "[":
                    box := @Box(pos, size=box_size)
                    w.boxes:insert(box)
                else if cell == "]":
                    pass # Ignored
                else if cell == "@":
                    pos += box_size/2 - Player.SIZE/2
                    w.player = @Player(pos,pos)
                else if cell == "?":
                    w.goal = Goal(pos)
                else if cell == "+":
                    w.satellites:insert(@Satellite(pos))
                else if cell == "*":
                    if random:bool(0.2):
                        w.stars:insert(Stars(pos, star_textures:random()))
                else if cell != " ":
                    w.letters:insert(Letter(CString(cell), pos))


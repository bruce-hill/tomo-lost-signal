
use vectors

use ./player.tm
use ./camera.tm
use ./color.tm
use ./box.tm
use ./letter.tm

# Return a displacement relative to `a` that will push it out of `b`
func solve_overlap(a_pos:Vec2, a_size:Vec2, b_pos:Vec2, b_size:Vec2 -> Vec2):
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
        return Vec2(0, 0)

    if overlap_x < overlap_y:
        if a_right > b_left and a_right < b_right:
            return Vec2(-(overlap_x), 0)
        else if a_left < b_right and a_left > b_left:
            return Vec2(overlap_x, 0)
    else:
        if a_top < b_bottom and a_top > b_top:
            return Vec2(0, overlap_y)
        else if a_bottom > b_top and a_bottom < b_bottom:
            return Vec2(0, -overlap_y)

    return Vec2(0, 0)

func overlaps(a_pos:Vec2, a_size:Vec2, b_pos:Vec2, b_size:Vec2 -> Bool):
    return solve_overlap(a_pos, a_size, b_pos, b_size) != Vec2(0, 0)

func draw_line(a,b:Vec2, width=10.0, color=Color(1,0,0)):
    inline C {
        DrawLineEx(
            ((Vector2){(float)_$a.$x, (float)_$a.$y}),
            ((Vector2){(float)_$b.$x, (float)_$b.$y}),
            (float)_$width,
            (Color){
                (uint8_t)(255.*_$color.$r),
                (uint8_t)(255.*_$color.$g),
                (uint8_t)(255.*_$color.$b),
                (uint8_t)(255.*_$color.$a),
            }
        );
    }

struct World(
    player:@Player,
    camera:@Camera,
    goal:@Box,
    control:Vec2,
    boxes:@[@Box],
    letters:@[Letter],
    dt_accum=0.0,
    won=no,
):
    DT := 1./60.
    CURRENT := @World(
        player=@Player(Vec2(0,0), Vec2(0,0)),
        camera=@Camera(Vec2(0,0)),
        goal=@Box(Vec2(0,0), Vec2(0,0), Color.GOAL),
        control=Vec2(0,0),
        boxes=@[:@Box],
        letters=@[:Letter],
    )
    STIFFNESS := 0.3

    func update(w:@World, dt:Num):
        w.dt_accum += dt
        while w.dt_accum > 0:
            w:update_once()
            w.dt_accum -= World.DT
        w.camera:follow(w.player.pos)
        w.camera:update(dt)

    func update_once(w:@World):
        w.player.has_signal = (w:raycast(w.control, w.player.pos) == w.player.pos)
        w.player:update()

        if overlaps(w.player.pos, Player.SIZE, w.goal.pos, w.goal.size):
            w.won = yes

        # Resolve player overlapping with any boxes:
        for i in 3:
            for b in w.boxes:
                correction := solve_overlap(w.player.pos, Player.SIZE, b.pos, b.size)
                #w.camera:add_shake(.1*correction:length())
                w.player.pos += World.STIFFNESS * correction

        w.camera:update(World.DT)

    func raycast(w:@World, start:Vec2, end:Vec2 -> Vec2):
        return end if start == end
        dist := start:dist(end)
        forward := (end - start)

        for b in w.boxes:
            x_min := b.pos.x - b.size.x/2
            x_max := b.pos.x + b.size.x/2
            y_min := b.pos.y - b.size.y/2
            y_max := b.pos.y + b.size.y/2

            times := [
                (x_min - start.x)/forward.x,
                (x_max - start.x)/forward.x,
                (y_min - start.y)/forward.y,
                (y_max - start.y)/forward.y,
            ]
            hit_time := (_min_: t for t in times if (0 <= t and t <= 1) and b:has_point(start + (t or skip)*forward))
            if hit_time:
                return start + hit_time*forward

        return end

    func draw(w:@World):
        do:
            w.camera:begin_drawing()
            defer: w.camera:end_drawing()

            for b in w.boxes:
                b:draw()

            for l in w.letters:
                l:draw()

            w.goal:draw()
            w.player:draw()

            hit := w:raycast(w.control, w.player.pos)
            draw_line(w.control, hit)
            #w.camera:draw()

        if w.won:
            inline C {
                DrawText("WINNER", GetScreenWidth()/2-48*3, GetScreenHeight()/2-24, 48, (Color){0,0,0,0xFF});
            }

    func load_map(w:@World, map:Text):
        if map:has($/[]/):
            map = map:replace_all({$/[]/="#", $/@{1..}/="@", $/  /=" "})
        w.boxes = @[:@Box]
        box_size := Vec2(50., 50.)
        for y,line in map:lines():
            for x,cell in line:split():
                pos := Vec2((Num(x)-1) * box_size.x, (Num(y)-1) * box_size.y)
                if cell == "#":
                    box := @Box(pos, size=box_size, color=Color.GRAY)
                    w.boxes:insert(box)
                else if cell == "@":
                    pos += box_size/2. - Player.SIZE/2.
                    w.player = @Player(pos,pos)
                else if cell == "?":
                    w.goal = @Box(pos, size=box_size, color=Color.GOAL)
                else if cell == "+":
                    w.control = pos
                else if cell != " ":
                    w.letters:insert(Letter(CString(cell), pos))


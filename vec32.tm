# A math vector library for 32-bit 2D vectors

struct Vec2(x,y:Num32):
    ZERO := Vec2(0, 0)
    func plus(a,b:Vec2->Vec2; inline):
        return Vec2(a.x+b.x, a.y+b.y)
    func minus(a,b:Vec2->Vec2; inline):
        return Vec2(a.x-b.x, a.y-b.y)
    func times(a,b:Vec2->Vec2; inline):
        return Vec2(a.x*b.x, a.y*b.y)
    func negative(v:Vec2->Vec2; inline):
        return Vec2(-v.x, -v.y)
    func dot(a,b:Vec2->Num32; inline):
        return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y)
    func cross(a,b:Vec2->Num32; inline):
        return a.x*b.y - a.y*b.x
    func scaled_by(v:Vec2, k:Num32->Vec2; inline):
        return Vec2(v.x*k, v.y*k)
    func divided_by(v:Vec2, divisor:Num32->Vec2; inline):
        return Vec2(v.x/divisor, v.y/divisor)
    func length(v:Vec2->Num32; inline):
        return (v.x*v.x + v.y*v.y)!:sqrt()
    func dist(a,b:Vec2->Num32; inline):
        return a:minus(b):length()
    func angle(v:Vec2->Num32; inline):
        return Num32.atan2(v.y, v.x)
    func norm(v:Vec2->Vec2; inline):
        if v.x == 0 and v.y == 0:
            return v
        len := v:length()
        return Vec2(v.x/len, v.y/len)
    func rotated(v:Vec2, radians:Num32 -> Vec2):
        cos := radians:cos() or return v
        sin := radians:sin() or return v
        return Vec2(cos*v.x - sin*v.y, sin*v.x + cos*v.y)
    func mix(a,b:Vec2, amount:Num32 -> Vec2):
        return Vec2(
            amount:mix(a.x, b.x),
            amount:mix(a.y, b.y),
        )

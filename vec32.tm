# A math vector library for 32-bit 2D vectors

struct Vector2(x,y:Num32):
    ZERO := Vector2(0, 0)
    func plus(a,b:Vector2->Vector2; inline):
        return Vector2(a.x+b.x, a.y+b.y)
    func minus(a,b:Vector2->Vector2; inline):
        return Vector2(a.x-b.x, a.y-b.y)
    func times(a,b:Vector2->Vector2; inline):
        return Vector2(a.x*b.x, a.y*b.y)
    func negative(v:Vector2->Vector2; inline):
        return Vector2(-v.x, -v.y)
    func dot(a,b:Vector2->Num32; inline):
        return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y)
    func cross(a,b:Vector2->Num32; inline):
        return a.x*b.y - a.y*b.x
    func scaled_by(v:Vector2, k:Num32->Vector2; inline):
        return Vector2(v.x*k, v.y*k)
    func divided_by(v:Vector2, divisor:Num32->Vector2; inline):
        return Vector2(v.x/divisor, v.y/divisor)
    func length(v:Vector2->Num32; inline):
        return (v.x*v.x + v.y*v.y)!:sqrt()
    func dist(a,b:Vector2->Num32; inline):
        return a:minus(b):length()
    func angle(v:Vector2->Num32; inline):
        return Num32.atan2(v.y, v.x)
    func norm(v:Vector2->Vector2; inline):
        if v.x == 0 and v.y == 0:
            return v
        len := v:length()
        return Vector2(v.x/len, v.y/len)
    func rotated(v:Vector2, radians:Num32 -> Vector2):
        cos := radians:cos() or return v
        sin := radians:sin() or return v
        return Vector2(cos*v.x - sin*v.y, sin*v.x + cos*v.y)
    func mix(a,b:Vector2, amount:Num32 -> Vector2):
        return Vector2(
            amount:mix(a.x, b.x),
            amount:mix(a.y, b.y),
        )

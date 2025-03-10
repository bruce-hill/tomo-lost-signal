use <raylib.h>

struct Texture(id,width,height,mipmaps,format:Int32):
    func load(path:Path; cached):
        return inline C : Texture {
            LoadTexture(Text$as_c_string(_$path));
        }

    func draw(t:Texture, pos:Vec2, rotation=Num32(0.0), scale=Num32(1.0), tint=Color.WHITE):
        inline C {
            DrawTextureEx(_$t, _$pos, _$rotation, _$scale, _$tint);
        }

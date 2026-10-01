extern float amount;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    if (amount <= 0.0005) {
        return Texel(texture, texture_coords) * color;
    }

    vec2 dist = texture_coords - 0.5;
    vec2 offset = dist * amount;

    float r = Texel(texture, texture_coords + offset).r;
    float g = Texel(texture, texture_coords).g;
    float b = Texel(texture, texture_coords - offset).b;
    float a = Texel(texture, texture_coords).a;

    return vec4(r, g, b, a) * color;
}

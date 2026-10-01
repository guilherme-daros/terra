extern vec2 screen_size;
extern float time;

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
    uv = (uv / 2.0) + 0.5;
    return uv;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = curve(texture_coords);
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    vec4 tex = Texel(texture, uv);

    // Scanline effect
    float scanline = sin(uv.y * screen_size.y * 3.14159) * 0.08;
    tex.rgb -= scanline;

    // Subtle CRT flicker
    float flicker = 1.0 - 0.015 * sin(time * 12.0);
    tex.rgb *= flicker;

    // Vignette corner darkening
    float vig = (16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
    vig = clamp(pow(vig, 0.22), 0.0, 1.0);
    tex.rgb *= vig;

    return tex * color;
}

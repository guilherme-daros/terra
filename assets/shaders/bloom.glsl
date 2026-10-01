extern vec2 screen_size;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 base = Texel(texture, texture_coords);
    vec4 sum = vec4(0.0);
    vec2 step = 1.6 / screen_size;

    sum += Texel(texture, texture_coords + vec2(-step.x, -step.y)) * 0.08;
    sum += Texel(texture, texture_coords + vec2(0.0, -step.y))     * 0.12;
    sum += Texel(texture, texture_coords + vec2(step.x, -step.y))  * 0.08;

    sum += Texel(texture, texture_coords + vec2(-step.x, 0.0))     * 0.12;
    sum += Texel(texture, texture_coords)                         * 0.20;
    sum += Texel(texture, texture_coords + vec2(step.x, 0.0))      * 0.12;

    sum += Texel(texture, texture_coords + vec2(-step.x, step.y))  * 0.08;
    sum += Texel(texture, texture_coords + vec2(0.0, step.y))      * 0.12;
    sum += Texel(texture, texture_coords + vec2(step.x, step.y))   * 0.08;

    vec4 glow = max(sum - 0.12, vec4(0.0)) * 1.5;
    return (base + glow) * color;
}

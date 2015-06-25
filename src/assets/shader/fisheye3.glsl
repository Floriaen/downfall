extern vec2 iResolution;
extern vec2 iMouse;
//uniform float lensSize; // 0.4
 
vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float lensSize = 0.4;

    vec2 p = screen_coords / iResolution.xy;
    vec2 m = iMouse / iResolution.xy;
 
    vec2 d = p - m;
    float r = sqrt(dot(d, d)); // distance of pixel from mouse
 
    vec2 uv;
    vec3 col = vec3(0.0, 0.0, 0.0);
    if (r > lensSize+0.01) 
    {
        uv = p;
        col = texture2D(texture, vec2(uv.x, -uv.y)).xyz;
    } 
    else if (r < lensSize-0.01) 
    {
        // Thanks to Paul Bourke for these formulas; see
        // http://paulbourke.net/miscellaneous/lenscorrection/
        // and .../lenscorrection/lens.c
        // Choose one formula to uncomment:
        // SQUAREXY:
        // uv = m + vec2(d.x * abs(d.x), d.y * abs(d.y));
        // SQUARER:
        uv = m + d * r; // a.k.a. m + normalize(d) * r * r
        // SINER:
        // uv = m + normalize(d) * sin(r * 3.14159 * 0.5);
        // ASINR:
        // uv = m + normalize(d) * asin(r) / (3.14159 * 0.5);
        col = texture2D(texture, vec2(uv.x, -uv.y)).xyz;
    }
    return vec4(col, 1.0);
}
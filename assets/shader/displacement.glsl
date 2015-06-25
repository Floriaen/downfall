uniform sampler2D texture;
uniform sampler2D displacementMap;
uniform sampler2D paletteMap;
uniform sampler2D gradientMap;

void main() {
    // Get the pixels off of the maps.
    vec4 displacementPixel = texture2D(displacementMap, gl_TexCoord[0]);
    vec4 palettePixel = texture2D(paletteMap, gl_TexCoord[0]);

    // Read the pixel from the displaced position.
    vec2 pos = gl_TexCoord[0];
    pos.x += (displacementPixel.r * 2.0 - 1.0) * 0.025;
    pos.y -= (displacementPixel.g * 2.0 - 1.0) * 0.025;

    // Get the displaced pixel.
    vec4 pixel = texture2D(texture, pos);

    // Proper grayscale conversion.
    float gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));

    // Get the color from the gradient.
    float gradientPos = mod(gray + palettePixel.g, 1);

    // Get the actual color from the gradient.
    vec4 gradientMapPixel = texture2D(gradientMap, new vec2(gradientPos, palettePixel.r));

    // Mix the gradient with the pixel color based on the palette pixel.
    pixel = mix(pixel, gradientMapPixel, palettePixel.a);

    // Apply the final color multiplied by the gl color.
    gl_FragColor = pixel * gl_Color;
}
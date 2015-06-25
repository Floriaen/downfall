// http://popscan.blogspot.fr/2012/04/fisheye-lens-equation-simple-fisheye.html
// http://www.geeks3d.com/20140213/glsl-shader-library-fish-eye-and-dome-and-barrel-distortion-post-processing-filters/
/*
const float PI = 3.1415926535;
extern float aperture;

extern vec2 resolution;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float apertureHalf = 0.5 * aperture * (PI / 180.0);
	float maxFactor = sin(apertureHalf);

	vec2 uv;
	vec2 xy = 2 * texture_coords - 1.0;
	float d = length(xy);
	if (d < (2 - maxFactor)) {
		d = length(xy * maxFactor);
		float z = sqrt(1.0 - d * d);
		float r = atan(d, z) / PI;// * 1.3;
		float phi = atan(xy.y, xy.x);

		uv.x = r * cos(phi) + 0.4;
		uv.y = r * sin(phi) + 0.4;
	} else {
		uv = texture_coords;
	}
	vec4 c = texture2D(texture, uv);
	return c;
}
*/


//uniform sampler2D tex0;
//varying vec4 Vertex_UV;
const float PI = 3.1415926535;
//uniform float BarrelPower;

uniform vec2 inCenter;
uniform vec2 resolution;
uniform float power;

vec2 Distort(vec2 p)
{
    float theta  = atan(p.y, p.x);
    float radius = length(p);
    radius = pow(radius, power);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    return 0.5 * (p + 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

	//vec2 center = vec2(1, 1);

//vec2 resolution = vec2(640, 640);
	vec2 center = (inCenter - resolution / 2) / resolution;

  vec2 xy = 2.0 * texture_coords - 1.0;
  vec2 uv;

  float d = length(xy);
  if (d < 1.0)
  {

  	xy.x -= center.x;
  	xy.y -= center.y;

    uv = Distort(xy);

    uv.x += center.x;
    uv.y += center.y;

  }
  else
  {
    uv = texture_coords;
  }

  vec4 c = texture2D(texture, uv);
  return c;
}
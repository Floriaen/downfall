extern number time;
extern number width;
extern number height;
vec2 resolution	= vec2(width, height);
//uniform sampler2D tex0;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec2 halfres = resolution/2.0;
	vec2 cPos = pixel_coords.xy;
	
	cPos.x -= 0.5*halfres.x*sin(time/2.0)+0.3*halfres.x*cos(time)+halfres.x;
	cPos.y -= 0.4*halfres.y*sin(time/5.0)+0.3*halfres.y*cos(time)+halfres.y;

	float cLength = length(cPos);
	
	vec2 uv	= pixel_coords/resolution-(cPos/cLength)*sin(cLength/30.0-time*10.0)/90.0;
	uv.y = 1 - uv.y; // flip to normal :p
	vec3 col = texture2D(_tex0_,uv).xyz;
	col = col * vec3(0.9, 0.8, 0.7);
	//col = col * vec3(0.9, 0, 0);
	
	// vec3 col = texture2D(_tex0_,uv).xyz * 50.0/cLength;

	return vec4(col, 1.0);
}
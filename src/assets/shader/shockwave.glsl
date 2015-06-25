//uniform sampler2D sceneTex; // 0
extern vec2 center; // Mouse position
extern number time; // effect elapsed time
extern vec3 shockParams; // 10.0, 0.8, 0.1
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{

  vec2 uv = texture_coords.xy;
  vec2 texCoord = uv;
  number distance = distance(uv, center);
  if ((distance <= (time + shockParams.z)) && (distance >= (time - shockParams.z)) ) {
    number diff = (distance - time);
    number powDiff = 1.0 - pow(abs(diff*shockParams.x), shockParams.y);
    number diffTime = diff * powDiff;
    vec2 diffUV = normalize(uv - center);
    texCoord = uv + (diffUV * diffTime);
  }
  //return vec4(1, 0, 0, 1);
  vec3 col = texture2D(_tex0_, texCoord).xyz;
  return vec4(col, 1.0);
}
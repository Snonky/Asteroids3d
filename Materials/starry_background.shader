shader_type canvas_item;
render_mode unshaded;

uniform float NUM_LAYERS = 5.;
uniform float TRAVEL_SPEED = .0004;
uniform float TILT = 0.0;
uniform float PAN = 0.0;
uniform float SWAY = 0.0;
const float PI = 3.14159;

float hash21(vec2 co){
    return fract(sin(dot(co, vec2(1.0,113.0)))*239.5453123);
}

mat2 rot(float a) {
	float s = sin(a), c = cos(a);
    return mat2(vec2(c, s), vec2(-s, c));
}

float star(vec2 uv, float size, float ray_stregth) {
	float col = 0.;
	float d = length(uv);
	
	col += size/d;
	col *= smoothstep(.05, .01, d) * .7;
	
	return col;
}

vec3 StarLayer(vec2 uv, float scale, float salt) {
	vec3 col = vec3(0.);
	uv *= scale;
	uv += salt;
	uv.x += SWAY;
	
	vec2 gv = fract(uv) - .5 ;
	vec2 gridcoord = floor(uv);
	// Pseudo random number for grid variance
	float r = hash21(gridcoord) - .5;
	
	// Randomly recenter cell
	
	col += star(gv + vec2(r*.9, fract(r * 24.23) - .5)*.9, .005 * r + 0.002, .5);
	col.z *= (1.+r);
	
	return col;
}

void fragment() {
	vec2 resolution = 1./SCREEN_PIXEL_SIZE;
	vec2 uv = (FRAGCOORD.xy - resolution * .5) / resolution.y;
	vec3 c = vec3(0.);
	uv.y += TILT;
	uv.x += PAN;
	
	for(float i = 0.; i < 1.; i+= 1./NUM_LAYERS) {
		float depth = fract(i+TIME*TRAVEL_SPEED*10.);
		float scale = mix(20., 0., depth);
		c += StarLayer(uv, scale, i*32.) * depth;
	}
	mediump vec4 o = vec4(c,1);
	COLOR = o;
}
shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;

void fragment() {
	float col = 0.0;
	col = smoothstep(.4, .5, abs(UV.x-.5)) * smoothstep(.5, .4, abs(UV.x-.5));
	col *= 1. - UV.y;
	col *= smoothstep(.0, .1, UV.y);
	col *= .3;
	ALBEDO = vec3(col,col,col);
}
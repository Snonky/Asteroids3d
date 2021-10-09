shader_type spatial;
render_mode blend_add, unshaded, cull_front;

void fragment() {
	float col = 1.0;
	col *= 1.0 - UV.y;
	col *= smoothstep(.5, .4, abs(UV.x - .5));
	col *= smoothstep(0, .15, UV.y);
	ALBEDO = vec3(col,col,col);
}
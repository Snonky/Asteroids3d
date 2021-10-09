shader_type canvas_item;
uniform float MarkerOffset;
uniform float MarkerAlpha;
uniform sampler2D MarkerTexture : hint_albedo;

void vertex() {
	VERTEX = vec2(VERTEX.x + MarkerOffset, VERTEX.y);
}

void fragment() {
	vec4 tex = texture(MarkerTexture, UV.xy);
	vec3 color = tex.rgb;
	float alpha = tex.a;

	COLOR.rgb = color;
	COLOR.a = MarkerAlpha * alpha;

}

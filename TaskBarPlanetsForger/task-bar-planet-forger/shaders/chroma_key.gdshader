shader_type canvas_item;

// Permite usar os assets gerados com fundo magenta sem pré-processamento.
// Use em sprites e VFX; não aplique em elementos de UI comuns.
uniform vec4 key_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float threshold : hint_range(0.0, 0.5) = 0.12;
uniform float edge_softness : hint_range(0.0, 0.25) = 0.03;

void fragment() {
	vec4 sampled = texture(TEXTURE, UV);
	float distance_to_key = distance(sampled.rgb, key_color.rgb);
	float alpha = smoothstep(threshold, threshold + edge_softness, distance_to_key);
	COLOR = vec4(sampled.rgb, sampled.a * alpha) * COLOR;
}

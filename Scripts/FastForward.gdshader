shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen : source_color;
uniform float brightness : hint_range(0.0, 0.1);
uniform int colorAmt : hint_range(2, 100);
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment()
{
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR.rgb += texture(screen, SCREEN_UV).rgb * brightness;
	COLOR.g = COLOR.g.snappedf(1/colorAmt); # doesnotwork
}

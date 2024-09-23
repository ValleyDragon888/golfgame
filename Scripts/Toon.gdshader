shader_type canvas_item;
render_mode unshaded;

uniform float colorAmt : hint_range(2, 100, 1);
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment()
{
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR.r = round(COLOR.r * colorAmt) / colorAmt;
	COLOR.g = round(COLOR.g * colorAmt) / colorAmt;
	COLOR.b = round(COLOR.b * colorAmt) / colorAmt;
}

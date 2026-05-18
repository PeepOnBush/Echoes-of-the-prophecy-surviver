shader_type canvas_item;

uniform float speed = 1.5;      
uniform float strength = 4.0;   
uniform float offset = 0.0;     
uniform float sway_height : hint_range(0.0, 1.0) = 0.2; // 0.6 means top 60% sways

void vertex() {
	// smoothstep creates a mask. 
	// At UV.y = 0.0 (top of image), mask is 1.0 (full sway).
	// At UV.y = sway_height (e.g. middle of image), mask smoothly becomes 0.0 (no sway).
	float sway_mask = smoothstep(sway_height, sway_height - 0.3, UV.y);
	
	float wind = sin((TIME + offset) * speed) * strength;
	
	VERTEX.x += wind * sway_mask;
}
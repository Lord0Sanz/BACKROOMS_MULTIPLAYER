shader_type canvas_item;

// VHS Blue Screen Effect Shader
uniform vec4 blue_color : source_color = vec4(0.1569, 0.1569, 0.8627, 1.0); // Classic VHS blue
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float static_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float time_speed : hint_range(0.0, 10.0) = 2.0;
uniform float flicker_speed : hint_range(0.0, 10.0) = 3.0;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_speed;

    // Base blue color
    vec4 color = blue_color;

    // Scanlines
    float scanline = sin(uv.y * 800.0 + time * 10.0) * 0.5 + 0.5;
    color.rgb *= 1.0 - (scanline * scanline_intensity);

    // Noise
    float noise = random(uv + time) * noise_intensity;
    color.rgb += noise;

    // Static flicker
    float flicker = sin(time * flicker_speed) * 0.1 + 0.9;
    color.rgb *= flicker;

    // Random static bursts
    float static_burst = step(0.995, random(uv + fract(time * 0.1))) * static_intensity;
    color.rgb += static_burst;

    // VHS tracking lines (occasional horizontal glitches)
    float glitch_line = step(0.999, random(vec2(uv.y + time * 0.5, time))) * 0.3;
    if (glitch_line > 0.0) {
        color.rgb = mix(color.rgb, vec3(1.0), glitch_line);
    }

    COLOR = color;
}
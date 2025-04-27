{
  temp,
  glowStrength,
  glowRadius,
  scanlineFrequency,
  scanlineIntensity,
  curvatureStrength,
  brightness,
  contrast,
  ...
}: let
  frag = ''
    precision highp float;
    varying vec2 v_texcoord;

    uniform sampler2D tex;
    uniform float time;

    const float COLOR_TEMPERATURE = ${builtins.toString temp};

    const float GLOW_STRENGTH = ${builtins.toString glowStrength};
    const float GLOW_RADIUS = ${builtins.toString glowRadius};

    const float SCANLINE_FREQUENCY =  ${builtins.toString scanlineFrequency};
    const float SCANLINE_INTENSITY = ${builtins.toString scanlineIntensity};

    const float CURVATURE_STRENGTH = ${builtins.toString curvatureStrength};

    const float BRIGHTNESS = ${builtins.toString brightness};
    const float CONTRAST = ${builtins.toString contrast};

    // Color Temperature to RGB conversion function
    vec3 colorTemperatureToRGB(const in float temperature) {
        mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                                vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                                vec3(1.0, 1.3302673723350029, 1.8993753891711275)) :
                                           mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                                vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                                vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
        return mix(
            clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
            vec3(1.0),
            smoothstep(1000.0, 0.0, temperature)
        );
    }

    void main() {
        vec2 tc = vec2(v_texcoord.x, v_texcoord.y);

        // Distance from the center
        float dx = abs(0.5 - tc.x);
        float dy = abs(0.5 - tc.y);

        // Square it to smooth the edges
        dx *= dx;
        dy *= dy;

        tc.x -= 0.5;
        tc.x *= 1.0 + (dy * CURVATURE_STRENGTH);
        tc.x += 0.5;

        tc.y -= 0.5;
        tc.y *= 1.0 + (dx * CURVATURE_STRENGTH);
        tc.y += 0.5;

        // Add RGB offset for retro color separation effect
        vec2 r_tc = tc + vec2(0.001, 0.0);
        vec2 g_tc = tc;
        vec2 b_tc = tc - vec2(0.001, 0.0);

        vec4 color;
        color.r = texture2D(tex, r_tc).r;
        color.g = texture2D(tex, g_tc).g;
        color.b = texture2D(tex, b_tc).b;
        color.a = 1.0;

        // Add scanlines
        float scanline = sin(tc.y * SCANLINE_FREQUENCY) * SCANLINE_INTENSITY;
        color.rgb += scanline;

        // Add noise
        float noise = (fract(sin(dot(tc.xy + vec2(time), vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.05;
        color.rgb += noise;

        color.rgb = clamp(color.rgb, 0.0, 1.0);
        // Add after noise/scanline additions

        // Apply vignette effect
        float vignette = smoothstep(0.6, 0.3, dx + dy);
        color.rgb *= vignette;

        // Vertical CRT lines
        float lines = sin((tc.y + time * 0.1) * 40.0) * 0.02;
        color.rgb *= 1.0 - lines;

        // Apply color temperature
        color.rgb *= colorTemperatureToRGB(COLOR_TEMPERATURE);

        // Apply retro orange color transformation
        vec3 retroColor = vec3(
            color.r * 1.1,  // Boost the red channel
            color.g * 1.0,  // Keep the green channel as is
            color.b * 0.9   // Reduce the blue channel
        );
        color.rgb = retroColor;

        // Glow
        vec3 glow = vec3(0.0);
        float samples = 0.0;
        for (float x = -2.0; x <= 2.0; x += 1.0) {
            for (float y = -2.0; y <= 2.0; y += 1.0) {
                vec2 offset = vec2(x, y) * GLOW_RADIUS;
                glow += texture2D(tex, tc + offset).rgb;
                samples += 1.0;
            }
        }
        glow /= samples;

        // Fixed glow blending (operate on RGB components)
        vec3 blendedGlow = mix(color.rgb, max(color.rgb, glow * 1.5), GLOW_STRENGTH);
        color.rgb = mix(color.rgb, blendedGlow, 0.8);

        // Cutoff
        if (tc.y > 1.0 || tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0)
            color = vec4(0.0);

        // Apply brightness & contrast
        color.rgb = (color.rgb - 0.5) * CONTRAST + 0.5 + BRIGHTNESS;

        gl_FragColor = color;
    }
  '';
in
  frag

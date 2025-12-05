package vis

import "core:fmt"
import rl "vendor:raylib"

// Light types
LightType :: enum {
	DIRECTIONAL,
	POINT,
}

// Light structure adapted from raylib's rlight.h
Light :: struct {
	enabled:    i32,
	light_type: LightType,
	position:   rl.Vector3,
	target:     rl.Vector3,
	color:      rl.Color,
	enable_loc: i32,
	type_loc:   i32,
	pos_loc:    i32,
	target_loc: i32,
	color_loc:  i32,
}

// Create a new light and set up its shader uniforms
light_create :: proc(
	index: uint,
	light_type: LightType,
	pos: rl.Vector3,
	target: rl.Vector3,
	color: rl.Color,
	shader: rl.Shader,
) -> Light {
	light: Light
	light.enabled = 1
	light.light_type = light_type
	light.position = pos
	light.target = target
	light.color = color

	// Get shader locations
	light.enable_loc = rl.GetShaderLocation(shader, fmt.ctprintf("lights[%d].enabled", index))
	light.type_loc = rl.GetShaderLocation(shader, fmt.ctprintf("lights[%d].type", index))
	light.pos_loc = rl.GetShaderLocation(shader, fmt.ctprintf("lights[%d].position", index))
	light.target_loc = rl.GetShaderLocation(shader, fmt.ctprintf("lights[%d].target", index))
	light.color_loc = rl.GetShaderLocation(shader, fmt.ctprintf("lights[%d].color", index))

	light_update(&light, shader)
	return light
}

// Update shader values for this light
light_update :: proc(light: ^Light, shader: rl.Shader) {
	// Send to shader light enabled state and type
	rl.SetShaderValue(shader, light.enable_loc, &light.enabled, .INT)
	l_type := i32(light.light_type)
	rl.SetShaderValue(shader, light.type_loc, &l_type, .INT)

	// Send to shader light position values
	position := [3]f32{light.position.x, light.position.y, light.position.z}
	rl.SetShaderValue(shader, light.pos_loc, &position, .VEC3)

	// Send to shader light target position values
	target := [3]f32{light.target.x, light.target.y, light.target.z}
	rl.SetShaderValue(shader, light.target_loc, &target, .VEC3)

	// Send to shader light color values (normalized to 0-1)
	color := [4]f32 {
		f32(light.color.r) / 255,
		f32(light.color.g) / 255,
		f32(light.color.b) / 255,
		f32(light.color.a) / 255,
	}
	rl.SetShaderValue(shader, light.color_loc, &color, .VEC4)
}

// Set up lighting shader with ambient light
setup_shader :: proc(ambient: f32) -> rl.Shader {
	shader := rl.LoadShader("resources/lighting.vs", "resources/lighting.fs")
	shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos")
	ambient_loc := rl.GetShaderLocation(shader, "ambient")
	ambient_val := [4]f32{ambient, ambient, ambient, 1.0}
	rl.SetShaderValue(shader, ambient_loc, &ambient_val, .VEC4)
	return shader
}

// A basic lighting setup with ambient light + some top-positioned lights
setup_lights :: proc(shader: rl.Shader, camera: rl.Camera3D) -> [dynamic]Light {
	lights := make([dynamic]Light)

	// Downwards light above camera target
	append(
		&lights,
		light_create(
			0,
			.POINT,
			rl.Vector3{camera.target.x, camera.position.y, camera.target.z},
			rl.Vector3{camera.target.x, 0, camera.target.z},
			rl.WHITE,
			shader,
		),
	)

	// Fill light above camera, also on target
	append(
		&lights,
		light_create(
			1,
			.POINT,
			rl.Vector3{camera.position.x, camera.position.y + 2, camera.position.z},
			rl.Vector3{camera.target.x, 1, camera.target.z},
			rl.WHITE,
			shader,
		),
	)

	return lights
}

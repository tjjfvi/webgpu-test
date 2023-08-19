struct Config {
  size: vec2<u32>,
  time: u32,
}

@group(0) @binding(0) var<storage, read> config : Config;
@group(0) @binding(1) var<storage, read_write> output : array<u32>;

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
  let index = global_id.x + global_id.y * config.size.x;

  if (global_id.x >= config.size.x || global_id.y >= config.size.y) { return; }

  let x = f32(global_id.x) / f32(config.size.x);
  let y = f32(global_id.y) / f32(config.size.y);

  let ang = f32(config.time) / 500.0;
  let distF = 3.0;
  let r = sin(ang + x * distF) / 2 + .5;
  let g = cos(ang + y * distF) / 2 + .5;
  let b = -sin(ang + (x - y) * (x + y) * distF) / 2 + .5;

  let color = vec4(r, g, b, 1);

  output[index] = 
      (clamp(u32(color.r * 255), 0, 255) << 0u)
    | (clamp(u32(color.g * 255), 0, 255) << 8u)
    | (clamp(u32(color.b * 255), 0, 255) << 16u)
    | (clamp(u32(color.a * 255), 0, 255) << 24u)
  ;
}


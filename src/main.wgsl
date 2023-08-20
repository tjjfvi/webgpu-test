struct Config {
  size: vec2<u32>,
  time: u32,
  iter: u32,
}

@group(0) @binding(0) var<storage, read> config : Config;
@group(0) @binding(1) var<storage, read_write> store : array<vec3f>;
@group(0) @binding(2) var<storage, read_write> output : array<u32>;

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
  let index = global_id.x + global_id.y * config.size.x;

  if (global_id.x >= config.size.x || global_id.y >= config.size.y) { return; }

  let theta = f32(config.time) / 1500;
  // let theta = radians(10);
  let phi = -sin(theta * 2) * radians(15);
  let z = normalize(vec3(cos(theta) * cos(phi), sin(phi), sin(theta) * cos(phi)));
  let y = vec3f(0, 1, 0);
  let x = normalize(cross(z, y));

  let camera_pos = 2 * z;
  let camera_fwd = -z;
  let camera_x = x;
  let camera_y = cross(x, z);

  let camera_size = 3.0;
  let fov = radians(60.0);
  let camera_depth = camera_size / sin(fov);
  let pixel_size = camera_size / f32(config.size.y);

  let pos = (vec2<f32>(global_id.xy) - vec2<f32>(config.size) / 2) * pixel_size;

  let dst = camera_pos + camera_x * pos.x + camera_y * pos.y;
  let src = camera_pos - camera_fwd * camera_depth;
  let dir = normalize(dst - src);
  let ray = Ray(src, dir);

  var color = vec4f();

  var i = 0u;
  for(; i < rounds; i++){
    color += raycast(ray, xrng(xrng(xrng(xrng(xrng(index) + config.iter)) + i)));
    if(color.a == 0) { i++; break; }
  }

  color /= f32(i);

  // store[index] += color;

  // color = store[index] / f32(config.iter + 1);

  output[index] = pack4x8unorm(vec4f(color.rgb, 1));
}
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

  // let theta = f32(config.time) / 1500;
  let theta = radians(60);
  let phi = -sin(theta * 2) * radians(15);
  let z = normalize(vec3(cos(theta) * cos(phi), sin(phi), sin(theta) * cos(phi)));
  let y = vec3f(0, 1, 0);
  let x = normalize(cross(z, y));

  let camera_pos = 5 * z;
  let camera_fwd = -z;
  let camera_x = x;
  let camera_y = cross(x, z);

  let fov = radians(60.0);
  let camera_depth = 5.0;
  let camera_size = camera_depth * sin(fov);
  let pixel_size = camera_size / f32(config.size.y);
  let blur_amount = .125;

  var color = vec3f();

  var i = 0u;
  for(; i < rounds; i++){
    rng = xrng(xrng(xrng(xrng(xrng(index) + config.iter)) + i));
    let pos = (vec2f(global_id.xy) + vec2f(rand(), rand()) - vec2f(config.size) / 2) * pixel_size;
    let dst = camera_pos + camera_x * pos.x + camera_y * pos.y + camera_fwd * camera_depth;
    let theta = rand() * tau;
    let r = sqrt(rand());
    let src = camera_pos + camera_x * cos(theta) * r * blur_amount + camera_y * sin(theta) * r * blur_amount;
    let dir = normalize(dst - src);
    let ray = Ray(src, dir);
    color += raycast(ray);
  }

  color /= f32(i);

  store[index] += color;
  color = store[index] / f32(config.iter + 1);

  output[index] = pack4x8unorm(vec4f(filmic(color), 1));
}

fn filmic(color: vec3f) -> vec3f {
    return 1 - (1/(5 * (color * color) + 1.));
}
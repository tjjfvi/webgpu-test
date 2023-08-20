struct Config {
  size: vec2<u32>,
  time: u32,
  iter: u32,
}

@group(0) @binding(0) var<storage, read> config : Config;
@group(0) @binding(1) var<storage, read_write> store : array<vec3f>;
@group(0) @binding(2) var<storage, read_write> output : array<u32>;

const tau = 6.283185307;

const rounds = 100u;

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
  let ang = normalize(dst - src);
  let ray = Ray(src, ang);

  var color = vec3f();

  for(var i = 0u; i < rounds; i++){
    color += raycast(ray, xrng(xrng(xrng(xrng(xrng(index) + config.iter)) + i)));
  }

  color /= f32(rounds);

  // store[index] += color;

  // color = store[index] / f32(config.iter + 1);

  output[index] = pack4x8unorm(vec4f(color, 1));
}

const red = vec3(1, .3, .3);
const green = vec3(.3, 1, .3);
const blue = vec3(.3, .3, 1);

const spheres = array<Sphere, 5>(
  Sphere(vec3(0, .1, 0), .1, Material(vec3f(), vec3f(10), 0)),
  Sphere(vec3(1, -.5, -0.5), .8, Material(vec3f(.9), vec3f(), .9)),
  Sphere(vec3(-.9, -.4, 0), .7, Material(red, vec3f(), 0)),
  Sphere(vec3(.7, 1.2, 0), .4, Material(blue, vec3f(), 0)),
  Sphere(vec3(-.7, -1, 1.2), .6, Material(vec3f(1), vec3f(), 0)),
);

const bounce_limit = 10;

const too_dark_2 = 0.01;

fn raycast(init_ray: Ray, _rng: u32) -> vec3f {
  var rng = _rng;

  var ray = init_ray;
  var ray_color = vec3f(1, 1, 1);
  var light = vec3f(0, 0, 0);

  for(var i = 0; i < bounce_limit; i++) {
    let hit = hit(ray);

    if(hit.dist >= inf) { 
      break;
    }

    let spot = ray.src + hit.dist * ray.ang;

    let t1 = perp(hit.norm);
    let t2 = cross(hit.norm, t1);

    rng = xrng(rng);
    let sin_t_2 = rand(rng);
    let sin_t = sqrt(sin_t_2);
    let cos_t = sqrt(1 - sin_t_2);

    rng = xrng(rng);
    let psi = rand(rng) * tau;

    let diffuse = (sin_t * cos(psi)) * t1 + (sin_t * sin(psi)) * t2 + cos_t * hit.norm;

    let specular = reflect(ray.ang, hit.norm);

    let out = lerp(diffuse, specular, hit.material.specularity);

    light += ray_color * hit.material.emission;
    ray_color *= hit.material.albedo;

    ray = Ray(spot, out);

    if(dot(ray_color, ray_color) <= too_dark_2) { break; }
  }

  light += ray_color * ambient(ray);

  return light;
}

const sky_color = vec3f(.6, .8, 1);
const sun_ang = normalize(vec3f(.7, -1, .3));
const sun_color = vec3f(1, 1, .8);
const base_color = sky_color * .1;

fn ambient(ray: Ray) -> vec3f {
  return (sky_color + pow(clamp(dot(sun_ang, ray.ang), 0, 1), 3) * sun_color) * clamp(-ray.ang.y, 0, 1) + base_color;
}

fn hit(ray: Ray) -> Hit {
  var best_hit = null_hit;

  for(var i = 0; i < 5; i++) {
    let hit = hit_sphere(ray, spheres[i]);
    if(hit.dist >= 0 && hit.dist < best_hit.dist) { best_hit = hit; }
  }

  return best_hit;
}

struct Ray {
  src: vec3f,
  ang: vec3f,
}

struct Material {
  albedo: vec3f,
  emission: vec3f,
  specularity: f32,
}

struct Sphere {
  center: vec3f,
  radius: f32,
  material: Material,
}

struct Hit {
  dist: f32,
  norm: vec3<f32>,
  material: Material,
}

const inf = 1e+38;

const null_hit = Hit(inf, vec3(), Material(vec3(), vec3(), 0));

fn hit_sphere(ray: Ray, sphere: Sphere) -> Hit {
  let src = ray.src - sphere.center;
  let ang = ray.ang;
  let r = sphere.radius;

  let b = dot(src, ang);
  let c = dot(src, src) - r * r;

  let d = b * b - c;

  if(d < 0) { return null_hit; }

  let t = -b - sqrt(d);

  return Hit(t, (src + t * ang) / r, sphere.material);
}

fn xrng(rng: u32) -> u32 {
  return rng * 747796405 + 2891336453;
}

fn rand(rng: u32) -> f32 {
  var result = ((rng >> ((rng >> 28) + 4)) ^ rng) * 277803737;
  result = (result >> 22) ^ result;
  return f32(result) / 4294967295.0;
}

fn perp(v: vec3f) -> vec3f {
  let sx = sign(v.x) + .5;
  let sy = sign(v.y) + .5;
  let sz = sign(v.z) + .5;
  let sxz = sign(sx * sz);
  let syz = sign(sy * sz);
  return normalize(vec3f(
    sxz * v.z,
    syz * v.z,
    - sxz * v.x - syz * v.y,
  ));
}

fn lerp(a: vec3f, b: vec3f, t: f32) -> vec3f {
  return a * (1-t) + b * t;
}

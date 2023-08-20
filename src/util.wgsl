
const tau = 6.283185307;

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


struct Sphere {
  center: vec3f,
  radius: f32,
  material: Material,
}

fn hit_sphere(ray: Ray, sphere: Sphere) -> Hit {
  let src = ray.src - sphere.center;
  let dir = ray.dir;
  let r = sphere.radius;

  let b = dot(src, dir);
  let c = dot(src, src) - r * r;

  let d = b * b - c;

  if(d < 0) { return null_hit; }

  let t = -b - sqrt(d);

  return Hit(t, (src + t * dir) / r, sphere.material);
}

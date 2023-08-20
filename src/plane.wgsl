
// {p | p . norm = w}
struct Plane {
  norm: vec3f,
  w: f32,
  material: Material,
}

fn hit_plane(ray: Ray, plane: Plane) -> Hit {
  // p = src + t dir
  // p . norm = w
  // (src + t dir) . norm = w
  // (src . norm) + t (dir . norm) = w
  // t = (w - (src . norm)) / (dir . norm)

  let d = dot(ray.dir, plane.norm);

  if(d >= 0) { return null_hit; }

  let t = (plane.w - dot(ray.src, plane.norm)) / d;

  return Hit(t, plane.norm, plane.material);
}

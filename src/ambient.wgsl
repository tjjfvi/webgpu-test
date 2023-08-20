
const sky_color = vec3f(.6, .8, 1);
const sun_dir = normalize(vec3f(.7, -1, .3));
const sun_color = vec3f(1, 1, .8);
const base_color = sky_color * .1;
const ambient_strength = .5;

fn ambient(ray: Ray) -> vec3f {
  return ambient_strength * ((sky_color + pow(clamp(dot(sun_dir, ray.dir), 0, 1), 3) * sun_color) * clamp(-ray.dir.y, 0, 1) + base_color);
}

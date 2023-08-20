
const sky_color = vec3f(.6, .8, 1);
const sun_ang = normalize(vec3f(.7, -1, .3));
const sun_color = vec3f(1, 1, .8);
const base_color = sky_color * .1;

fn ambient(ray: Ray) -> vec3f {
  return (sky_color + pow(clamp(dot(sun_ang, ray.ang), 0, 1), 3) * sun_color) * clamp(-ray.ang.y, 0, 1) + base_color;
}

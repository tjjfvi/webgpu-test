
const rounds = 100u;

const bounce_limit = 10;

const too_dark_2 = 0.01;

fn raycast(init_ray: Ray, _rng: u32) -> vec4f {
  var rng = _rng;

  var ray = init_ray;
  var ray_color = vec3f(1, 1, 1);
  var light = vec3f(0, 0, 0);
  var diffuseness = 0.;

  for(var i = 0; i < bounce_limit; i++) {
    let hit = hit_scene(ray);

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
    diffuseness += (1 - hit.material.specularity);

    ray = Ray(spot, out);

    if(dot(ray_color, ray_color) <= too_dark_2) { break; }
  }

  light += ray_color * ambient(ray);

  return vec4f(light, diffuseness);
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

struct Hit {
  dist: f32,
  norm: vec3<f32>,
  material: Material,
}

const inf = 1e+38;

const null_hit = Hit(inf, vec3(), Material(vec3(), vec3(), 0));

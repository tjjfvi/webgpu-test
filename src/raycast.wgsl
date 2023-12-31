
const rounds = 100u;

const bounce_limit = 10;

const too_dark_2 = 0.01;

fn raycast(init_ray: Ray) -> vec3f {
  var ray = init_ray;
  var ray_color = vec3f(1, 1, 1);
  var light = vec3f(0, 0, 0);

  for(var i = 0; i < bounce_limit; i++) {
    let hit = hit_scene(ray);

    if(hit.dist >= inf) { 
      break;
    }

    // return vec4f(hit.norm * hit.norm, 0) * 1 / hit.dist;

    let spot = ray.src + hit.dist * ray.dir;

    let t1 = perp(hit.norm);
    let t2 = cross(hit.norm, t1);

    let sin_t_2 = rand();
    let sin_t = sqrt(sin_t_2);
    let cos_t = sqrt(1 - sin_t_2);

    let psi = rand() * tau;

    let diffuse = (sin_t * cos(psi)) * t1 + (sin_t * sin(psi)) * t2 + cos_t * hit.norm;

    let specular = reflect(ray.dir, hit.norm);

    let out = lerp(diffuse, specular, hit.material.specularity);

    light += ray_color * hit.material.emission;
    ray_color *= hit.material.albedo;

    ray = Ray(spot, out);

    if(dot(ray_color, ray_color) <= too_dark_2) { break; }
  }

  light += ray_color * ambient(ray);

  return vec3f(light);
}

struct Ray {
  src: vec3f,
  dir: vec3f,
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

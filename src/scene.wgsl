
const red = vec3(1, .3, .3);
const green = vec3(.3, 1, .3);
const blue = vec3(.3, .3, 1);

const sphere_count = 5;
const spheres = array<Sphere, sphere_count>(
  Sphere(vec3(0, .1, 0), .1, Material(vec3f(), vec3f(20), 0)),
  Sphere(vec3(1, -.5, -0.5), .8, Material(vec3f(.9), vec3f(), 1)),
  Sphere(vec3(-.9, -.4, 0), .7, Material(red, vec3f(), 0)),
  Sphere(vec3(.7, 1.2, 0), .4, Material(blue, vec3f(), 0)),
  Sphere(vec3(-.7, -1, 1.2), .6, Material(vec3f(1), vec3f(), 0)),
);

const cube_material = Material(vec3f(.3), vec3f(), 0);
const cube_center = vec3(-.7, 1.2, 0);
const cube_halfsize = .4;

const bsp_roots_count = 2;
const bsp_roots = array<u32, bsp_roots_count>(
  0,
  1,
);
const bsp_count = 7;
const bsps = array<Bsp, bsp_count>(
  Bsp(vec3(0, -1, 0), -1.6, Material(vec3f(.3), vec3f(), 0), 0, 0),
  Bsp(vec3(1, 0, 0), (cube_center.x + cube_halfsize), cube_material, 2, 0),
  Bsp(vec3(0, 1, 0), (cube_center.y + cube_halfsize), cube_material, 3, 0),
  Bsp(vec3(0, 0, 1), (cube_center.z + cube_halfsize), cube_material, 4, 0),
  Bsp(vec3(-1, 0, 0), -(cube_center.x - cube_halfsize), cube_material, 5, 0),
  Bsp(vec3(0, -1, 0), -(cube_center.y - cube_halfsize), cube_material, 6, 0),
  Bsp(vec3(0, 0, -1), -(cube_center.z - cube_halfsize), cube_material, 0, 0),
);

fn hit_scene(ray: Ray) -> Hit {
  var best_hit = null_hit;

  for(var i = 0; i < sphere_count; i++) {
    let hit = hit_sphere(ray, spheres[i]);
    if(hit.dist >= 0 && hit.dist < best_hit.dist) { best_hit = hit; }
  }

  for(var i = 0; i < bsp_roots_count; i++) {
    let hit = hit_bsp(ray, bsp_roots[i]);
    if(hit.dist >= 0 && hit.dist < best_hit.dist) { best_hit = hit; }
  }

  return best_hit;
}

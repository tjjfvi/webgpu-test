
const red = vec3(1, .3, .3);
const green = vec3(.3, 1, .3);
const blue = vec3(.3, .3, 1);

const sphere_count = 5;
const spheres = array<Sphere, sphere_count>(
  Sphere(vec3(0, .1, 0), .1, Material(vec3f(), vec3f(10), 0)),
  Sphere(vec3(1, -.5, -0.5), .8, Material(vec3f(.9), vec3f(), .9)),
  Sphere(vec3(-.9, -.4, 0), .7, Material(red, vec3f(), 0)),
  Sphere(vec3(.7, 1.2, 0), .4, Material(blue, vec3f(), 0)),
  Sphere(vec3(-.7, -1, 1.2), .6, Material(vec3f(1), vec3f(), 0)),
);

const plane_count = 1;
const planes = array<Plane, plane_count>(
  Plane(vec3(0, -1, 0), -1.6, Material(vec3f(.3), vec3f(), 0)),
);

fn hit_scene(ray: Ray) -> Hit {
  var best_hit = null_hit;

  for(var i = 0; i < sphere_count; i++) {
    let hit = hit_sphere(ray, spheres[i]);
    if(hit.dist >= 0 && hit.dist < best_hit.dist) { best_hit = hit; }
  }

  for(var i = 0; i < plane_count; i++) {
    let hit = hit_plane(ray, planes[i]);
    if(hit.dist >= 0 && hit.dist < best_hit.dist) { best_hit = hit; }
  }

  return best_hit;
}

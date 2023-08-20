
struct Bsp {
  norm: vec3f,
  w: f32,
  material: Material,
  in: u32,
  out: u32,
}

struct BspStackEntry {
  index: u32,
  near: f32,
  far: f32,
  hit: Hit,
}

const bsp_stack_max = 128;

const debug_hit = Hit(1, vec3f(1), null_hit.material);

var<private> bsp_stack: array<BspStackEntry, bsp_stack_max>;

fn hit_bsp(ray: Ray, index: u32) -> Hit {
  var cur = BspStackEntry(index, epsilon, inf, null_hit);
  var stack_next = 0u;
  var best_hit = null_hit;

  while(true){
    let near = cur.near;
    let far = cur.far;
    let hit = cur.hit;
    let bsp = bsps[cur.index];

    let d = dot(ray.dir, bsp.norm);

    var t = (bsp.w - dot(ray.src, bsp.norm)) / d;

    let front = d < 0;
    let head = select(bsp.in, bsp.out, front);
    let tail = select(bsp.out, bsp.in, front);

    let in_near = t > near;
    if(in_near && head == 0 && !front) {
      return hit;
    }

    let in_far = t < far;

    var new_hit = hit;
    if(in_near && in_far && front) {
      new_hit = Hit(t, bsp.norm, bsp.material);
    }

    if(in_far && tail == 0 && front) {
      best_hit = new_hit;
    }

    var pushed = false;
    if(in_far && tail != 0) {
      cur = BspStackEntry(tail, max(near, t), far, new_hit);
      pushed = true;
    }

    if(in_near && head != 0){
      if(pushed) {
        bsp_stack[stack_next] = cur;
        stack_next++;
      }
      cur = BspStackEntry(head, near, min(far, t), hit);
      pushed = true;
    }

    if(!pushed){
      if(stack_next == 0) { break; }
      stack_next--;
      cur = bsp_stack[stack_next];
    }
  }

  return best_hit;
}

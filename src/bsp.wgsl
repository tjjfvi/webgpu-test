
struct Bsp {
  norm: vec3f,
  w: f32,
  material: Material,
  in: u32,
  out: u32,
}

fn hit_bsp(_ray: Ray, _bsp: Bsp) -> Hit {
  var keepSearching = true;
  for(var i = 0; keepSearching; i++){
    keepSearching = false;
    var ray = _ray;
    var bsp = _bsp;
    var hit = null_hit;
    var far = inf;
    var total_dist = 0f;
    var n = i;

    while(true){
      let d = dot(ray.dir, bsp.norm);

      var t = (bsp.w - dot(ray.src, bsp.norm)) / d;

      var short = bsp.out;
      var long = bsp.in;

      if(d > 0) {
        long = bsp.out;
        short = bsp.in;
      }

      if(t > 0){
        if(short == 0) {
          if(d > 0) {
            return hit;
          }
        } else {
          let branch = n & 1;
          n = n >> 1;
          if(branch == 0) {
            far = min(far, t);
            bsp = bsps[short];
            keepSearching = true;
            continue;
          }
        }
      }

      if(t > far) { break; }

      if(t > 0) {
        total_dist += t;
        ray.src = ray.src + t * ray.dir;
        far -= t;
        t = 0;

        if(d < 0) {
          hit = Hit(total_dist, bsp.norm, bsp.material);
        }
      }

      if(long == 0) {
        if(d < 0) {
          return hit;
        } else {
          break;
        }
      }

      bsp = bsps[long];
    }
  }

  return null_hit;
}

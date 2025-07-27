#valtype
pub struct LinearScanKNN {
  dimension : Int
}

pub fn LinearScanKNN::new(dimension : Int) -> LinearScanKNN {
  LinearScanKNN::{ dimension }
}



pub fn LinearScanKNN::search_by(self : LinearScanKNN, point: Point, n : Int) -> Array[Point] {
  // squared Euclidean distance
  fn dist(x : Point, y : Point) -> UInt64 {
    let mut sum = 0UL
    for i in 0..<self.dimension {
      // avoid overflow
      let diff = (x[i] - y[i]).to_int64().abs().reinterpret_as_uint64()
      sum += diff * diff
    }
    return sum
  }
  let heap = @priority_queue.new()
  
  ...
}
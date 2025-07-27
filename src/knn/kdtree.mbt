///|
pub struct KDTree {
  point : Point
  partition_axis : Int
  left : KDTree?
  right : KDTree?
}

///|


///|
pub fn KDTree::is_leaf(self : KDTree) -> Bool {
  return self.left is None && self.right is None && self.partition_axis == -1
}

///|
pub fn KDTree::singleton(point : Point) -> KDTree {
  return KDTree::{
    point,
    partition_axis: -1, // No partition axis for a singleton
    left: None,
    right: None,
  }
}

///|
fn[T] KDTree::partition_by(arr : ArrayView[T], get_key : (T) -> Int) -> Int {
  let lo = 0
  let hi = arr.length() - 1
  let pivot = get_key(arr[hi])
  let mut i = lo - 1
  for j in lo..<hi {
    if get_key(arr[j]) <= pivot {
      i += 1
      arr.swap(i, j)
    }
  }
  arr.swap(i + 1, hi)
  return i + 1
}

///| select the k-th smallest element in the arr
fn[T] KDTree::quickselect_by(
  arr : ArrayView[T],
  k : Int,
  get_key : (T) -> Int,
) -> T {
  if arr.length() == 1 {
    return arr[0]
  }
  let pivot_index = KDTree::partition_by(arr, get_key)
  if k == pivot_index {
    return arr[k]
  } else if k < pivot_index {
    return KDTree::quickselect_by(arr[:pivot_index], k, get_key)
  } else {
    return KDTree::quickselect_by(arr[pivot_index + 1:], k, get_key)
  }
}

///|
test "select k-th smallest element" {
  let id = x => x
  let arr = [1, 1, 2, 3, 3, 5, 6, 7, 8, 9]
  inspect(KDTree::quickselect_by(arr, 0, id), content="1")
  inspect(KDTree::quickselect_by(arr, 1, id), content="1")
  inspect(KDTree::quickselect_by(arr, 2, id), content="2")
  inspect(KDTree::quickselect_by(arr, 3, id), content="3")
  inspect(KDTree::quickselect_by(arr, 4, id), content="3")
  inspect(KDTree::quickselect_by(arr, 5, id), content="5")
  let arr2 = [0]
  inspect(KDTree::quickselect_by(arr2, 0, id), content="0")
}

///|
fn[T] KDTree::split_by_midvalue(
  arr : ArrayView[T],
  get_key : (T) -> Int,
) -> (ArrayView[T], T, ArrayView[T]) {
  // TODO: BFPRT https://en.wikipedia.org/wiki/Median_of_medians
  let mid = arr.length() / 2
  ignore(KDTree::quickselect_by(arr, mid, get_key))
  (arr[:mid], arr[mid], arr[mid + 1:])
}

///|
test "split by midvalue" {
  let id = x => x
  let arr = [1, 2, 3, 4, 5]
  let (left, mid, right) = KDTree::split_by_midvalue(arr, id)
  inspect(left, content="[1, 2]")
  inspect(mid, content="3")
  inspect(right, content="[4, 5]")
  let arr2 = [1]
  let (left2, mid2, right2) = KDTree::split_by_midvalue(arr2, id)
  inspect(left2, content="[]")
  inspect(mid2, content="1")
  inspect(right2, content="[]")
  let arr3 = [1, 2, 2, 3, 4]
  let (left3, mid3, right3) = KDTree::split_by_midvalue(arr3, id)
  inspect(left3, content="[1, 2]")
  inspect(mid3, content="2")
  inspect(right3, content="[3, 4]")
  let arr4 = [1, 2, 3, 3, 4]
  let (left4, mid4, right4) = KDTree::split_by_midvalue(arr4, id)
  inspect(left4, content="[1, 2]")
  inspect(mid4, content="3")
  inspect(right4, content="[3, 4]")
  let arr3 = [1, 2, 3, 4, 5, 6]
  let (left3, mid3, right3) = KDTree::split_by_midvalue(arr3, id)
  inspect(left3, content="[1, 2, 3]")
  inspect(mid3, content="4")
  inspect(right3, content="[5, 6]")
}

///|
pub fn KDTree::from(points : ArrayView[Point], k : Int) -> KDTree {
  fn go(points : ArrayView[Point], depth : Int) -> KDTree? {
    if points.length() == 0 {
      return None
    } else {
      let axis = depth % k
      let (left, point, right) = KDTree::split_by_midvalue(points, p => p[axis])
      let left = go(left, depth + 1)
      let right = go(right, depth + 1)
      return Some(KDTree::{ point, partition_axis: axis, left, right })
    }
  }
  guard go(points, 0) is Some(tree)
  return tree
}

///|
struct UnionFind {
  parents : Array[Id]
} derive(Default)

///|
pub fn UnionFind::size(self : UnionFind) -> Int {
  self.parents.length()
}

///|
pub fn make_set(self : UnionFind) -> Id {
  let id = Id(self.size().reinterpret_as_uint())
  self.parents.push(id)
  id
}

///|
pub fn parent(self : UnionFind, query : Id) -> Id {
  self.parents[query._.reinterpret_as_int()]
}

///|
pub fn UnionFind::find(self : UnionFind, current : Id) -> Id {
  loop current {
    x => if x != self.parent(x) { continue self.parent(x) } else { break x }
  }
}

///|
pub fn UnionFind::union(self : UnionFind, r1 : Id, r2 : Id) -> Id {
  self.parents[r2._.reinterpret_as_int()] = r1
  r1
}

///|
test "union find" {
  fn ids(n) -> Array[Id] {
    Array::makei(n, fn(i) { Id(i.to_uint()) })
  }

  let n = 10
  let uf = UnionFind::default()
  for _ in 0..<n {
    uf.make_set() |> ignore
  }
  assert_eq!(uf.parents, ids(n))
  uf.union(0, 1) |> ignore
  uf.union(0, 2) |> ignore
  uf.union(0, 3) |> ignore
  uf.union(6, 7) |> ignore
  uf.union(6, 8) |> ignore
  uf.union(6, 9) |> ignore
  for i in 0..<n {
    uf.find(i.to_uint()) |> ignore
  }
  assert_eq!(uf.parents, [
    Id(0),
    Id(0),
    Id(0),
    Id(0),
    Id(4),
    Id(5),
    Id(6),
    Id(6),
    Id(6),
    Id(6),
  ])
}

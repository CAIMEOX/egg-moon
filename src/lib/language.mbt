// type Discriminant Symbol

///|
trait Language: Hash + Eq + Compare + Clone {
  discirminant(Self) -> Symbol
  mathces(Self, Self) -> Bool
  children(Self) -> ArrayView[Id]
  children_mut(Self) -> Array[Id]
}

///|
trait Clone {
  clone(Self) -> Self
}

///|
pub fn[L : Language] each(l : L, f : (Id) -> Unit) -> Unit {
  l.children().each(f)
}

///|
pub fn[T, L : Language] fold(l : L, f : (T, Id) -> T, init : T) -> T {
  let mut acc = init
  for id in l.children() {
    acc = f(acc, id)
  }
  acc
}

///|
pub fn[L : Language] all(l : L, f : (Id) -> Bool) -> Bool {
  fold(l, fn(acc, id) { acc && f(id) }, true)
}

///|
pub fn[L : Language] any(l : L, f : (Id) -> Bool) -> Bool {
  fold(l, fn(acc, id) { acc || f(id) }, false)
}

///|
pub fn[L : Language] update_children(l : L, f : (Id) -> Id) -> Unit {
  l.children_mut().map_inplace(f)
}

///|
pub fn[L : Language] map_children_inplace(l : L, f : (Id) -> Id) -> L {
  update_children(l, f)
  l
}

///|
struct RecExpr[L] {
  nodes : Array[L]
} derive(Default)

///|
pub fn[L] ids(self : RecExpr[L]) -> Array[Id] {
  Array::makei(self.nodes.length(), fn(i) { Id(i.reinterpret_as_uint()) })
}

///|
pub fn[L] root(self : RecExpr[L]) -> Id {
  self.ids().last().unwrap()
}

///|
pub fn[L] RecExpr::add(self : RecExpr[L], node : L) -> Id {
  self.nodes.push(node)
  self.root()
}

///|
pub fn[L, T] RecExpr::fold(self : RecExpr[L], init~ : T, f : (T, Id) -> T) -> T {
  let mut acc = init
  for id in self.ids() {
    acc = f(acc, id)
  }
  acc
}

///|
pub fn[L] RecExpr::length(self : RecExpr[L]) -> Int {
  self.fold(init=0, fn(len, _) { len + 1 })
}

///|
pub fn[T : Language + Eq + Hash] compact(self : RecExpr[T]) -> RecExpr[T] {
  let ids = @moonbitlang/core/hashmap.new()
  let set = Set::new()
  for i, node in self.nodes.drain(0, self.nodes.length()) {
    let node = map_children_inplace(node, id => ids.get(id).unwrap())
    let new_id = set.add(node)
    ...
  }
  self.nodes.append(set.iter().to_array())
  self
}

///|
pub fn[L] RecExpr::iter(self : RecExpr[L]) -> Iter[L] {
  self.nodes.iter()
}

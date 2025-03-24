// type Discriminant Symbol

///|
trait Discriminant {}

///|
trait Language {
  discirminant() -> (Self) -> &Discriminant
  mathces(Self, Self) -> Bool
  children(Self) -> ArrayView[Id]
  children_mut(Self) -> Array[Id]
}

///|
pub fn each[L : Language](l : L, f : (Id) -> Unit) -> Unit {
  l.children().each(f)
}

///|
pub fn fold[T, L : Language](l : L, f : (T, Id) -> T, init : T) -> T {
  let mut acc = init
  for id in l.children() {
    acc = f(acc, id)
  }
  acc
}

///|
pub fn all[L : Language](l : L, f : (Id) -> Bool) -> Bool {
  fold(l, fn(acc, id) { acc && f(id) }, true)
}

///|
pub fn any[L : Language](l : L, f : (Id) -> Bool) -> Bool {
  fold(l, fn(acc, id) { acc || f(id) }, false)
}

///|
pub fn update_children[L : Language](l : L, f : (Id) -> Id) -> Unit {
  l.children_mut().map_inplace(f)
}

///|
pub fn map_children[L : Language](l : L, f : (Id) -> Id) -> L {
  update_children(l, f)
  l
}

///|
struct RecExpr[L] {
  nodes : Array[L]
} derive(Default)

///|
pub fn ids[L](self : RecExpr[L]) -> Array[Id] {
  Array::makei(self.nodes.length(), fn(i) { Id(i.reinterpret_as_uint()) })
}

///|
pub fn root[L](self : RecExpr[L]) -> Id {
  self.ids().last().unwrap()
}

///|
pub fn RecExpr::add[L : Language](self : RecExpr[L], node : L) -> Id {
  self.nodes.push(node)
  self.root()
}

///|
pub fn compact[T : Language + Eq + Hash](self : RecExpr[T]) -> RecExpr[T] {
  let ids = @moonbitlang/core/hashmap.new()
  let set = Set::new()
  for i, node in self.nodes.drain(0, self.nodes.length()) {
    let node = map_children(node, fn { id => ids[id].unwrap() })
    let new_id = set.add(node)
    ...
  }
  self.nodes.append(set.iter().to_array())
  self
}

///|
struct EClass[L, D] {
  id : Id
  nodes : Array[L]
  data : D
  parents : Array[Id]
}

///|
pub fn is_empty[L, D](self : EClass[L, D]) -> Bool {
  self.nodes.is_empty()
}

///|
pub fn length[L, D](self : EClass[L, D]) -> Int {
  self.nodes.length()
}

///|
pub fn iter[L, D](self : EClass[L, D]) -> Iter[L] {
  self.nodes.iter()
}

///|
pub fn parents[L, D](self : EClass[L, D]) -> Iter[Id] {
  self.parents.iter()
}

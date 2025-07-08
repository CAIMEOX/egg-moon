///|
struct EClass[L] {
  id : Id
  nodes : Array[L]
  parents : Array[Id]
}

///|
pub fn[L] is_empty(self : EClass[L]) -> Bool {
  self.nodes.is_empty()
}

///|
pub fn[L] length(self : EClass[L]) -> Int {
  self.nodes.length()
}

///|
pub fn[L] iter(self : EClass[L]) -> Iter[L] {
  self.nodes.iter()
}

///|
pub fn[L] parents(self : EClass[L]) -> Iter[Id] {
  self.parents.iter()
}

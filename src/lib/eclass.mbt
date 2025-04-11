///|
struct EClass[L] {
  id : Id
  nodes : Array[L]
  parents : Array[Id]
}

///|
pub fn is_empty[L](self : EClass[L]) -> Bool {
  self.nodes.is_empty()
}

///|
pub fn length[L](self : EClass[L]) -> Int {
  self.nodes.length()
}

///|
pub fn iter[L](self : EClass[L]) -> Iter[L] {
  self.nodes.iter()
}

///|
pub fn parents[L](self : EClass[L]) -> Iter[Id] {
  self.parents.iter()
}

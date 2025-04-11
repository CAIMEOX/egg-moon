///|
pub struct EGraph[L, N] {
  analysis : N
  explain : Explain[L]?
  nodes : Array[L]
  memo : Map[L, Id]
  pending : Array[Id]
  analysis_pending : Unit // TODO: UniqueQueue
  classes : Map[Id, EClass[L]]
  classes_by_op : Map[Symbol, Set[Id]]
  clean : Bool
}

///|
pub fn EGraph::new[L, N](n : N) -> EGraph[L, N] {
  {
    analysis: n,
    explain: None,
    nodes: [],
    memo: Map::new(),
    pending: [],
    analysis_pending: (),
    classes: Map::new(),
    classes_by_op: Map::new(),
    clean: false,
  }
}

///|
pub fn classes[L, N](self : EGraph[L, N]) -> Iter[EClass[L]] {
  self.classes.values()
}

pub fn EGraph::is_empty[L, N](self: EGraph[L, N]) -> Bool {
  self.memo.is_empty()
}
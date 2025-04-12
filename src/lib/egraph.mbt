///|
pub struct EGraph[L, N] {
  analysis : N
  union_find : UnionFind
  nodes : Array[L]
  memo : Map[L, Id]
  pending : Array[Id]
  analysis_pending : Unit // TODO: UniqueQueue
  classes : Map[Id, EClass[L]]
  classes_by_op : Map[Symbol, Set[Id]]
  mut clean : Bool
}

///|
pub fn EGraph::new[L, N](n : N) -> EGraph[L, N] {
  {
    analysis: n,
    nodes: [],
    memo: Map::new(),
    union_find: UnionFind::default(),
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

///|
pub fn EGraph::is_empty[L, N](self : EGraph[L, N]) -> Bool {
  self.memo.is_empty()
}

///|
pub fn add_expr[L : Language, N](self : EGraph[L, N], expr : RecExpr[L]) -> Id {
  let id = self.add_expr_uncanonical(expr)
  self.find(id)
}

///|
pub fn EGraph::find[L, N](self : EGraph[L, N], id : Id) -> Id {
  self.union_find.find(id)
}

///|
pub fn add_expr_uncanonical[L : Language, N](
  self : EGraph[L, N],
  expr : RecExpr[L]
) -> Id {
  let new_ids = Array::new(capacity=expr.length())
  let new_node_q = Array::new(capacity=expr.length())
  for node in expr {
    let new_node = node.clone()
      |> map_children_inplace(fn(id) { new_ids[id._.reinterpret_as_int()] })
    let size_before = self.union_find.size()
    let next_id = self.add_uncanonical(new_node)
    new_node_q.push(self.union_find.size() > size_before)
    new_ids.push(next_id)
  }
  new_ids.last().unwrap()
}

///|
pub fn lookup_internal[L : Language, N](self : EGraph[L, N], node : L) -> Id? {
  node |> update_children(fn(id) { self.find(id) })
  self.memo[node]
}

///|
pub fn add_uncanonical[L : Language, N](self : EGraph[L, N], node : L) -> Id {
  let original = node.clone()
  if self.lookup_internal(node) is Some(e_id) {
    let id = self.find(e_id)
    id
  } else {
    let id = self.make_new_elcass(node, original.clone())
    self.clean = false
    id
  }
}

///|
pub fn EGraph::op_get[L, N](self : EGraph[L, N], id : Id) -> EClass[L] {
  let id = self.find(id)
  self.classes[id].unwrap()
}

///|
pub fn make_new_elcass[L : Language, N](
  self : EGraph[L, N],
  node : L,
  original : L
) -> Id {
  let id0 = self.union_find.make_set()
  let class = { id: id0, nodes: [node.clone()], parents: Default::default() }
  self.nodes.push(original)
  node.children().each(fn(id) { self[id].parents.push(id0) })
  self.pending.push(id0)
  self.classes[id0] = class
  id0
}

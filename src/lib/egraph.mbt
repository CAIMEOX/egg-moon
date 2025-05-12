///|
pub struct EGraph[L, N] {
  analysis : N
  union_find : UnionFind
  nodes : Array[L]
  memo : Map[L, Id]
  pending : Array[Id]
  analysis_pending : Unit // TODO: UniqueQueue
  classes : Map[Id, EClass[L]]
  mut classes_by_op : Map[Symbol, Set[Id]]
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

///|
pub fn process_unions[L : Language, N](self : EGraph[L, N]) -> UInt {
  let mut n_unions = 0U
  while not(self.pending.is_empty()) {
    if self.pending.pop() is Some(class) {
      let node = self.nodes[class._.reinterpret_as_int()].clone()
      node |> update_children(fn(id) { self.union_find.find_mut(id) })
      match self.memo.get(node) {
        Some(old) => {
          self.memo[node] = class
          let did_sth = self.perform_union(
            old,
            class,
            Some(Justification::Congruence),
          )
          n_unions += did_sth.to_uint()
        }
        None => self.memo[node] = class
      }
    }
  }
  guard self.pending.is_empty()
  n_unions
}

///|
pub fn perform_union[L : Language, N](
  self : EGraph[L, N],
  enode_id1 : Id,
  enode_id2 : Id,
  _rule : Justification?
) -> Bool {
  // todo: pre_union hook for N
  self.clean = false
  let mut id1 = self.union_find.find_mut(enode_id1)
  let mut id2 = self.union_find.find_mut(enode_id2)
  // todo : explain 
  if id1 == id2 {
    return false
  }
  let class1_parents = self.classes.get(id1).unwrap().parents.length()
  let class2_parents = self.classes.get(id2).unwrap().length()
  if class1_parents < class2_parents {
    let tmp = id1
    id1 = id2
    id2 = tmp
  }
  // todo : explain
  self.union_find.union(id1, id2) |> ignore
  guard id1 != id2
  self.classes.remove(id2)
  let class2 = self.classes.get(id2).unwrap()
  let class1 = self.classes.get(id1).unwrap()
  self.pending.append(class2.parents.copy())
  // todo: analysis
  class1.nodes.append(class2.nodes)
  class1.parents.append(class2.parents)
  true
}

///|
pub fn rebuild[L : Language, N](self : EGraph[L, N]) -> UInt {
  let old_hc_size = self.memo.size()
  let old_n_eclasses = self.classes.size()
  let n_unions = self.process_unions()
  let _ = self.rebuild_classes()
  self.clean = true
  n_unions
}

///|
pub fn rebuild_classes[L : Language, N](self : EGraph[L, N]) -> Int {
  let classes_by_op = self.classes_by_op
  self.classes_by_op = Map::default()
  for ids in classes_by_op.values() {
    ids.clear()
  }
  let mut trimmed = 0
  let uf = self.union_find
  for class in self.classes.values() {
    let old_len = class.length()
    for n in class.nodes {
      n |> update_children(fn(id) { uf.find_mut(id) })
    }
    class.nodes.sort()
    class.nodes.dedup()
    trimmed += old_len - class.nodes.length()
    let add = fn {
      (n : L) =>
        match classes_by_op.get(L::discirminant(n)) {
          Some(set) => set.add(class.id)
          None => {
            let set = Set::new()
            set.add(class.id)
            classes_by_op[L::discirminant(n)] = set
          }
        }
    }
    if not(class.nodes.is_empty()) {
      let prev = class.nodes[0]
      add(prev)
      for n in class.nodes[1:] {
        if not(prev.mathces(n)) {
          add(n)
          class.nodes[0] = n
        }
      }
    }
  }
  self.classes_by_op = classes_by_op
  trimmed
}

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
pub fn[L, N] EGraph::new(n : N) -> EGraph[L, N] {
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
pub fn[L, N] classes(self : EGraph[L, N]) -> Iter[EClass[L]] {
  self.classes.values()
}

///|
pub fn[L, N] number_of_classes(self : EGraph[L, N]) -> Int {
  self.classes.size()
}

///|
pub fn[L, N] EGraph::is_empty(self : EGraph[L, N]) -> Bool {
  self.memo.is_empty()
}

///|
pub fn[L : Language, N] add_expr(self : EGraph[L, N], expr : RecExpr[L]) -> Id {
  let id = self.add_expr_uncanonical(expr)
  self.find(id)
}

///|
pub fn[L, N] EGraph::find(self : EGraph[L, N], id : Id) -> Id {
  self.union_find.find(id)
}

///|
pub fn[L : Language, N] EGraph::union(
  self : EGraph[L, N],
  id1 : Id,
  id2 : Id
) -> Bool {
  self.perform_union(id1, id2, None)
}

///|
pub fn[L, N] classes_for_op(self : EGraph[L, N], op : Symbol) -> Iter[Id]? {
  self.classes_by_op.get(op).map(Set::iter)
}

///|
pub fn[L : Language, N] add_expr_uncanonical(
  self : EGraph[L, N],
  expr : RecExpr[L]
) -> Id {
  let new_ids = Array::new(capacity=expr.length())
  let new_node_q = Array::new(capacity=expr.length())
  for node in expr {
    let new_node = node.clone()
      |> map_children_inplace(fn(id) {
        new_ids[id.inner().reinterpret_as_int()]
      })
    let size_before = self.union_find.size()
    let next_id = self.add_uncanonical(new_node)
    new_node_q.push(self.union_find.size() > size_before)
    new_ids.push(next_id)
  }
  new_ids.last().unwrap()
}

///|
pub fn[L : Language, N] lookup_internal(self : EGraph[L, N], node : L) -> Id? {
  node |> update_children(fn(id) { self.find(id) })
  self.memo[node]
}

///|
pub fn[L, N] total_size(self : EGraph[L, N]) -> Int {
  self.memo.size()
}

///|
pub fn[L : Language, N] add_uncanonical(self : EGraph[L, N], node : L) -> Id {
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
pub fn[L, N] EGraph::op_get(self : EGraph[L, N], id : Id) -> EClass[L] {
  let id = self.find(id)
  self.classes[id].unwrap()
}

///|
pub fn[L : Language, N] add(self : EGraph[L, N], node : L) -> Id {
  let id = self.add_uncanonical(node)
  self.union_find.find(id)
}

///|
pub fn[L : Language, N] make_new_elcass(
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
pub fn[L : Language, N] process_unions(self : EGraph[L, N]) -> UInt {
  let mut n_unions = 0U
  while not(self.pending.is_empty()) {
    if self.pending.pop() is Some(class) {
      let node = self.nodes[class.inner().reinterpret_as_int()].clone()
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
pub fn[L : Language, N] perform_union(
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
pub fn[L : Language, N] rebuild(self : EGraph[L, N]) -> UInt {
  let old_hc_size = self.memo.size()
  let old_n_eclasses = self.classes.size()
  let n_unions = self.process_unions()
  let _ = self.rebuild_classes()
  self.clean = true
  n_unions
}

///|
pub fn[L : Language, N] rebuild_classes(self : EGraph[L, N]) -> Int {
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

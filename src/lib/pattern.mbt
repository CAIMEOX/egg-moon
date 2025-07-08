///|
struct SearchMatches[L] {
  eclass : Id
  substs : Array[Subst]
  ast : RecExpr[ENodeOrVar[L]]?
}

///|
struct Pattern[L] {
  ast : RecExpr[ENodeOrVar[L]]
  program : Program[L]
}

///|
pub fn[L : Language, A] apply_matches(
  self : Pattern[L],
  egraph : EGraph[L, A],
  matches : Array[SearchMatches[L]]
  // rule_name : Symbol
) -> Array[Id] {
  let added = []
  let id_buf : Array[Id] = [0, Id(self.ast.length().reinterpret_as_uint())]
  for mat in matches {
    let sast = mat.ast
    for subst in mat.substs {
      let id = apply_pat(id_buf, self.ast, egraph, subst)
      if egraph.union(id, mat.eclass) {
        added.push(id)
      }
    }
  }
  added
}

///|
pub fn[L : Language, A] apply_pat(
  ids : Array[Id],
  pat : RecExpr[ENodeOrVar[L]],
  egraph : EGraph[L, A],
  subst : Subst
) -> Id {
  for i, pat_node in pat.iter() {
    let id = match pat_node {
      Var(w) => subst[w].unwrap()
      ENode(e) => {
        let n = e.clone()
          |> map_children_inplace(child => {
            guard child is Id(i)
            ids[i.reinterpret_as_int()]
          })
        egraph.add(n)
      }
    }
    ids[i] = id
  }
  ids.last().unwrap()
}

///|
pub fn[L] get_pattern_ast(self : Pattern[L]) -> RecExpr[ENodeOrVar[L]] {
  self.ast
}

///|
pub fn[L : Language, N] search_with_limit(
  self : Pattern[L],
  egraph : EGraph[L, N],
  limit : Int
) -> Array[SearchMatches[L]] {
  match self.ast.nodes.last().unwrap() {
    ENode(e) => {
      let key = e.discirminant()
      match egraph.classes_for_op(key) {
        None => []
        Some(ids) => self.search_eclasses_with_limit(egraph, ids, limit)
      }
    }
    Var(_) =>
      self.search_eclasses_with_limit(
        egraph,
        egraph.classes().map(e => e.id),
        limit,
      )
  }
}

///|
enum ENodeOrVar[L] {
  ENode(L)
  Var(Var)
}

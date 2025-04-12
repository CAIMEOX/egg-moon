///|
struct Runner[L, N] {
  egraph : EGraph[L, N]
  roots : Array[Id]
  stop_reason : String?
  limits : Limit
}

///|
pub fn Runner::new[L, N](analysis : N) -> Runner[L, N] {
  {
    egraph: EGraph::new(analysis),
    roots: [],
    stop_reason: None,
    limits: { node_limit: 10000 },
  }
}

///|
impl[L, N : Default] Default for Runner[L, N] with default() {
  Runner::new(N::default())
}

pub fn with_expr[L: Language, N](self: Runner[L, N], expr : RecExpr[L]) -> Runner[L, N] {
  let id = self.egraph.add_expr(expr)
  self.roots.push(id)
  self
}

///|
struct Limit {
  node_limit : UInt
}

///|
struct Scheduler[Ty, L, N] {
  can_stop : (Ty, UInt) -> Bool
  search_rewrite : (Ty, UInt, EGraph[L, N], Rewrite[L, N]) -> Array[
    SearchMatches[L],
  ]
  apply_rewrite : (Ty, UInt, EGraph[L, N], Array[SearchMatches[L]]) -> UInt
}

///|
type SimpleScheduler[L, N] Scheduler[Unit, L, N]

///|
pub fn impl_simple_scheduler[L, N]() -> SimpleScheduler[L, N] {
  {
    can_stop: fn { _, _ => true },
    search_rewrite: fn(_, _, egraph, rewrite) { rewrite.search(egraph) },
    apply_rewrite: fn {  },
  }
}

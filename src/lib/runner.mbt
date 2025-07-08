///|
struct Runner[L, N] {
  egraph : EGraph[L, N]
  roots : Array[Id]
  stop_reason : String?
  limits : Limit
  scheduler : SimpleScheduler
}

///|
suberror StopReason {
  NodeLimitExceeded
}

///|
pub fn[L, N] Runner::new(analysis : N) -> Runner[L, N] {
  {
    egraph: EGraph::new(analysis),
    scheduler: s(),
    roots: [],
    stop_reason: None,
    limits: { node_limit: 10000 },
  }
}

///|
pub impl[L, N : Default] Default for Runner[L, N] with default() {
  Runner::new(N::default())
}

///|
pub fn[L : Language, N] with_expr(
  self : Runner[L, N],
  expr : RecExpr[L]
) -> Runner[L, N] {
  let id = self.egraph.add_expr(expr)
  self.roots.push(id)
  self
}

///|
pub fn[L, N] run(self : Runner[L, N], rules : Iter[Rewrite[L, N]]) -> Unit {
  
}

///|
pub fn[L, N] check_limits(self : Runner[L, N]) -> Unit raise StopReason {
  self.limits.check_limits(self.egraph)
}

///|
pub fn[L, N, IterData] run_one(
  self : Runner[L, N],
  rules : Iter[Rewrite[L, N]]
) -> Iter[IterData] {
  let egraph_nodes = self.egraph.total_size()
  let egraph_classes = self.egraph.number_of_classes()
  // todo : hooks

  let mut matches = []
  let applied = @im.new()
  let result = self
    .check_limits()
    .bind(_ => matches = self.scheduler.search_rewrite()
  ...
}

///|
struct Limit {
  node_limit : UInt
}

///|
pub fn[L, N] Limit::check_limits(
  self : Limit,
  egraph : EGraph[L, N]
) -> Unit raise StopReason {
  if egraph.total_size() > self.node_limit.reinterpret_as_int() {
    raise NodeLimitExceeded
  }
}

///|
struct Scheduler[Ty, L, N] {
  can_stop : (Ty, UInt) -> Bool
  search_rewrite : (Ty, UInt, EGraph[L, N], Rewrite[L, N]) -> Array[
    SearchMatches[L],
  ]
  apply_rewrite : (
    Ty,
    UInt,
    EGraph[L, N],
    Rewrite[L, N],
    Array[SearchMatches[L]],
  ) -> UInt
}

///|
type SimpleScheduler

///|
// type SimpleScheduler[L, N] Scheduler[Unit, L, N]

pub fn SimpleScheduler::can_stop(
  _self : SimpleScheduler,
  _iteration : UInt
) -> Bool {
  true
}

///|
pub fn[L, N] SimpleScheduler::search_rewrite(
  _self : SimpleScheduler,
  _iteration : UInt,
  egraph : EGraph[L, N],
  rewrite : Rewrite[L, N]
) -> Array[SearchMatches[L]] {
  rewrite.search(egraph)
}

///|
pub fn[L : Language, N] SimpleScheduler::apply_rewrite(
  _self : SimpleScheduler,
  _iteration : UInt,
  egraph : EGraph[L, N],
  rw : Rewrite[L, N],
  matches : Array[SearchMatches[L]]
) -> UInt {
  rw.apply(egraph, matches).length().reinterpret_as_uint()
}

///|
pub fn[L : Language, N] SimpleScheduler::search_rewrites(
  self : SimpleScheduler,
  iteration : UInt,
  egraph : EGraph[L, N],
  rewrites : Iter[Rewrite[L, N]],
  limits : Limit
) -> Array[Array[SearchMatches[L]]] raise StopReason {
  let matches = []
  for rw in rewrites {
    let m = self.search_rewrite(iteration, egraph, rw)
    matches.push(m)
    limits.check_limits(egraph)
  }
  matches
}

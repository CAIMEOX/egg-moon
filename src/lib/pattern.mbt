///|
struct SearchMatches[L] {
  eclass : Id
  substs : Array[Subst]
  ast : RecExpr[ENodeOrVar[L]]?
}

struct Pattern[L] {
  ast: RecExpr[ENodeOrVar[L]]
  program: Program[L]
}

///|
enum ENodeOrVar[L] {
  ENode(L)
  Var(Id)
}

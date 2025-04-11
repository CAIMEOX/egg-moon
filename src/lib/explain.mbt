///|
enum Justification {
  Rule(Symbol)
  Congruence
}

///|
struct Connection {
  next : Id
  current : Id
  justification : Justification
  is_rw_forward : Bool
}

///|
pub struct ExplainNode {
  neighbors : Array[Connection]
  parent_connection : Connection
}

///|
pub struct Explain[L] {
  explain_find : Array[ExplainNode]
  un_canon_memo : Map[L, Id]
  optimize_explain_lengths : Bool
}

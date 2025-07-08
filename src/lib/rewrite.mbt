///|
struct Rewrite[L, N] { // This Ty is added by Searcher
  name : Symbol
  searcher : Pattern[L]
  applier : Pattern[L]
}

///|
pub fn[L, N] Rewrite::new(
  name : Symbol,
  searcher : Pattern[L],
  applier : Pattern[L]
) -> Rewrite[L, N] {
  { name, searcher, applier }
}

///|
pub fn[L : Language, N] apply(
  self : Rewrite[L, N],
  egraph : EGraph[L, N],
  matches : Array[SearchMatches[L]]
) -> Array[Id] {
  self.applier.apply_matches(egraph, matches)
}

///|
pub fn[L : Language, N] search(
  self : Rewrite[L, N],
  egraph : EGraph[L, N]
) -> Array[SearchMatches[L]] {
  self.searcher.search(egraph)
}

///|
pub fn[L : Language, N] search_eclasses_with_limit(
  self : Pattern[L],
  egraph : EGraph[L, N],
  eclasses : Iter[Id],
  limit : Int
) -> Array[SearchMatches[L]] {
  let mut limit = limit
  let matches = []
  for eclass in eclasses {
    guard limit != 0 else { break }
    match self.search_eclass_with_limit(egraph, eclass, limit) {
      Some(m) => {
        let len = m.substs.length()
        guard len <= limit 
        limit -= len
        matches.push(m)
      }
      None => ()
    }
  }
  matches
}

pub fn[L : Language, N] search_eclass_with_limit(
  self: Pattern[L],
  egraph: EGraph[L, N],
  eclass: Id,
  limit: Int
) -> SearchMatches[L]? {
  // let substs = self.program.
  ...
}

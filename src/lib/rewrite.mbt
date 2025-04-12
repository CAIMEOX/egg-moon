///|
struct Rewrite[L, N] { // This Ty is added by Searcher
  name : Symbol
  search : Pattern[L]
  apply : Applier[L, N]
}

///|
pub fn Rewrite::new[L, N](
  name : Symbol,
  search : Pattern[L],
  apply : Applier[L, N]
) -> Rewrite[L, N] {
  { name, search, apply }
}

///|
struct Searcher[Ty, L, N] {}

///|
struct Applier[L, N] {}
